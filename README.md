# GoChat

GoChat is a modern real-time chat application built with Flutter. It provides seamless messaging with real-time updates using WebSockets and offline message support via Firebase Cloud Messaging (FCM). It also includes video and audio calling features built from scratch using WebRTC, and supports a wide range of media sharing.

## ✨ Features

- 🔌 **Real-Time Chat** using WebSocket
- 📴 **Offline Messaging Support** using Firebase Cloud Messaging (FCM)
- 🎥 **Video & Audio Calling** using WebRTC (no third-party UI/config used)
- 💾 **Local Storage** using SQLite for storing messages and chats
- 💬 **Message Types**:
  - Text
  - Image
  - Video
  - Audio
  - Document
  - Contact
  - Location
- 📥 **Message Acknowledgements**:
  - Sent ✅
  - Received 📬
  - Seen 👀
- 🧠 Built from scratch with full control over chat flow and media handling

## 🛠 Tech Stack

- **Frontend:** Flutter
- **Backend:** Go (Golang) + WebSocket
- **Offline Messaging:** Firebase Cloud Messaging
- **Calling:** WebRTC (peer-to-peer)
- **Database:** SQLite (`sqflite` package)

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nihal2908/gochat_client.git
   cd gochat
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**:
   - Add `google-services.json` to `android/app`
   - Add `GoogleService-Info.plist` to `ios/Runner`

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
│
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Firebase, WebSocket, WebRTC, etc.
├── widgets/        # Reusable UI widgets
├── db/             # Local database helpers
└── main.dart       # Entry point
```

## 🔒 Security

- End-to-end encryption (planned)
- Token-based authentication

## 📌 Roadmap

- [x] Real-time WebSocket chat
- [x] FCM-based offline delivery
- [x] SQLite chat storage
- [x] WebRTC video/audio calls
- [x] Message acknowledgements
- [x] Sharing media/files
- [ ] Sharing location/contact
- [ ] End-to-end encryption
- [ ] Group chats
- [ ] Message reactions

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
