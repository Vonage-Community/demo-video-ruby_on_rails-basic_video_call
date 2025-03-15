import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

// Connects to data-controller="video-room"
export default class extends Controller {
  static values = {
    apiKey: String,
    sessionId: String,
    uuid: String,
    participantName: String,
    token: String,
  }
  
  connect() {
    this.room = new VideoExpress.Room({
      apiKey: this.apiKeyValue,
      sessionId: this.sessionIdValue,
      participantName: this.participantNameValue,
      token: this.tokenValue,
      roomContainer: 'room-container',
      
    });
    
    this.room.join();
  }

  disconnect() {
    this.room.leave();
  }

 async end() {
    let data = { participants: this.room.participants };
    const response = await post(`/video_calls/${this.uuidValue}/end_call`, {
      body: JSON.stringify(data),
      headers: { 'Content-Type': 'application/json' },
      responseType: 'json'
    });
  }
}