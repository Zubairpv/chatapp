# Chat App

## Description
This is a group-based chat application that allows users to communicate via text and voice messages. The app includes features for user authentication, text messaging, and voice messaging within groups.

## Features
- **Authentication:** Users can sign up, log in, and securely authenticate to access the app's features.
- **Text Messaging:** Users can send and receive text messages within groups.
- **Voice Messaging:** Users can record and send voice messages within groups.

## Dependencies
- **firebase_auth: ^4.3.0:** Firebase Authentication for user authentication.
- **firebase_core: ^2.8.0:** Firebase Core for initializing Firebase services.
- **shared_preferences: ^2.0.20:** For storing user preferences locally.
- **cloud_firestore: ^4.4.5:** Firestore as a backend database for storing chat messages.
- **carousel_slider: ^4.2.1:** For displaying carousel-style user interface elements.
- **image_picker: ^0.8.7+2:** For selecting images from the device's gallery.
- **firebase_storage: ^11.1.0:** Firebase Storage for storing media files such as images and voice messages.
- **permission_handler: ^10.2.0:** For handling runtime permissions.
- **flutter_sound: ^9.2.13:** For recording and playing voice messages.
- **provider: ^6.0.5:** For state management.
- **just_audio: ^0.9.32:** For playing audio files.
- **path_provider: ^2.1.2:** For accessing the device's file system paths.

## Installation
1. Clone the repository: `git clone https://github.com/Zubairpv/chatapp.git`
2. Navigate to the project directory: `cd chat_app`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Configuration
Before running the app, make sure to configure Firebase services by following the Firebase setup guide.

## Usage
1. Sign up or log in to the app.
2. Create or join a group.
3. Start sending text or voice messages within the group.
4. user can add or edit their profile 

## Contributors
- SubairPv(https://github.com/Zubairpv)
