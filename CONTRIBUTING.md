# BiGun - Audio Story Sharing App

## Project Overview
BiGun is a social media application where users can share audio stories. The app features a modern, minimalist design with a focus on audio visualization and smooth user interactions.

## Project Structure
```
lib/
├── components/
│   ├── audio_story_card.dart    # Card widget for displaying audio stories
│   ├── audio_wave_visualizer.dart # Audio waveform visualization
│   └── record_button.dart       # Custom recording button with animations
├── screens/
│   └── feed_screen.dart         # Main feed screen showing audio stories
├── models/                      # Data models
├── utils/                       # Utility functions and constants
└── main.dart                    # App entry point
```

## Key Features
1. **Audio Recording**
   - Long-press to record functionality
   - Real-time waveform visualization
   - Proper file handling and permissions
   - Error handling and user feedback

2. **Audio Playback**
   - Waveform visualization during playback
   - Tap-to-seek functionality
   - Play/pause controls
   - Progress tracking

3. **UI/UX**
   - Dark theme
   - Modern, minimalist design
   - Smooth animations
   - Responsive layout

## Technical Details

### Dependencies
- `just_audio`: Audio playback
- `record`: Audio recording
- `permission_handler`: Platform permissions
- `path_provider`: File system access

### Platform Support
- Android
- iOS
- Web (with some limitations)

### Key Components

#### RecordButton
- Uses `SingleTickerProviderStateMixin` for animations
- Handles microphone permissions
- Manages temporary file storage
- Provides real-time amplitude data

#### AudioWaveVisualizer
- Custom painting for waveform display
- Supports both playback and recording visualization
- Optimized for performance

#### AudioStoryCard
- Handles audio playback
- Displays waveform visualization
- Manages play/pause state

## Best Practices

### Code Style
1. Use meaningful variable and function names
2. Keep functions small and focused
3. Add comments for complex logic
4. Use const constructors when possible
5. Follow Flutter's style guide

### Performance
1. Minimize setState() calls
2. Use const widgets where appropriate
3. Dispose controllers and subscriptions
4. Cache computed values
5. Optimize rebuild cycles

### Error Handling
1. Handle all platform permissions
2. Provide user feedback for errors
3. Implement proper file cleanup
4. Handle edge cases (no storage, no permissions)

### Testing
1. Write widget tests for UI components
2. Test error scenarios
3. Verify platform-specific behavior
4. Test audio handling edge cases

## Common Issues & Solutions

### Web Platform
1. **Audio Recording**: Use web-specific implementation
2. **File System**: Handle through browser APIs
3. **Permissions**: Request through browser dialog

### Mobile Platforms
1. **Permissions**: Request at runtime
2. **File Storage**: Use temporary directory
3. **Background Audio**: Handle lifecycle events

## Future Improvements
1. Add user authentication
2. Implement cloud storage
3. Add social features (likes, comments)
4. Enhance audio processing
5. Add offline support
6. Implement push notifications

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## Development Setup
1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get`
4. Configure platform-specific settings
5. Run the app with `flutter run` 