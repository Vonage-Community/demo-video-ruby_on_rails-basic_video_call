import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="join-room"
export default class extends Controller {
  static values = {
    apiKey: String,
    sessionId: String,
    participantName: String,
    token: String,
  }
  
  connect() {
    const room = new VideoExpress.Room({
      apiKey: this.apiKeyValue,
      sessionId: this.sessionIdValue,
      participantName: this.participantNameValue,
      token: this.tokenValue,
      roomContainer: 'room-container',
      
    });

    room.join();
  }
}