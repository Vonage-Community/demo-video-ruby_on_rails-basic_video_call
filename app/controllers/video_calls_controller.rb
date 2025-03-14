class VideoCallsController < ApplicationController
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
    qr = ::RQRCode::QRCode.new("https://kyan.com")
    puts qr.to_s
    @video_call = VideoCall.find_by!(uuid: params[:uuid])
    @token = Vonage.video.generate_client_token(session_id: @video_call.session_id) if session[:participant_name].present?
  end

  def join
    @video_call = VideoCall.find_by(uuid: params[:uuid])
    session[:participant_name] = params[:participant_name]
  
    redirect_to @video_call
  end

  private

  def video_call_params
    params.require(:video_call).permit(:name)
  end
end
