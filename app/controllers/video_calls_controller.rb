class VideoCallsController < ApplicationController
  allow_unauthenticated_access except: %i[ index new create end_call ]

  def index
    @video_calls = VideoCall.all.order(:status)
  end
  
  def new
    @video_call = VideoCall.new
  end

  def create
    @video_call = VideoCall.new(
      application_id: ENV['VONAGE_APPLICATION_ID'],
      uuid: SecureRandom.uuid,
      **video_call_params
    )

    begin
      vonage_video_session = Vonage.video.create_session
      @video_call.session_id = vonage_video_session.session_id

      if @video_call.save
        redirect_to @video_call
      else
        flash[:alert] = "Unable to create video call."
        render :new, status: :unprocessable_entity 
      end
    rescue => error
      logger.info(error)
      flash[:alert] = "Unable to create video call."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @video_call = VideoCall.find_by(uuid: params[:uuid])

    unless @video_call && @video_call.active?
      render 'video_calls/not_found', status: :not_found
      return 
    end

    @qr = generate_qr_code(@video_call)
    @token = Vonage.video.generate_client_token(session_id: @video_call.session_id) if session[:participant_name].present?
    render layout: 'video_call'
  end

  def join
    @video_call = VideoCall.find_by(uuid: params[:uuid])
    session[:participant_name] = params[:participant_name]
  
    redirect_to @video_call
  end

  def end_call
    video_call = VideoCall.find_by(uuid: params[:uuid])
    participants = params[:participants]
    
    video_call.update!(status: 'ended')
    disconnect_participants(video_call, participants) if participants
    head :no_content
  end

  private

  def video_call_params
    params.require(:video_call).permit(:name)
  end

  def generate_qr_code(video_call)
    RQRCode::QRCode.new(
      "#{ENV['SITE_URL']}/video_calls/#{video_call.uuid}",
    ).as_svg
  end

  def disconnect_participants(video_call, participants)
    participants.keys.each do |participant_id|
      begin
        Vonage.video.moderation.force_disconnect(session_id: video_call.session_id, connection_id: participant_id)
      rescue => error
        logger.info(error)
      end
    end
  end
end
