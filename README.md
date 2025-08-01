# VisReminder
A visual reminding app for iOS and macOS that helps you remember tasks through visual cues.

## Overview

VisReminder is a simple yet powerful app that lets you take a picture, set a reminder time, and get notified later with the visual context you captured. Perfect for remembering where you left something, what you were working on, or any situation where a visual reminder is more effective than text.

**Take a picture. Set a time. Be reminded later.**

## Features

### Core Functionality
- **Visual Reminders**: Capture photos as reminders instead of just text
- **Flexible Timing**: Set reminders for specific times or intervals
- **Cross-Platform**: Works on both iOS and macOS
- **Apple Reminders Integration**: Seamless sync with Apple's native Reminders app
- **Smart Filtering**: Filter by All, Active, Overdue, Upcoming, or Completed
- **Search Capability**: Find reminders by title or notes

### User Experience
- **Intuitive Interface**: Simple, clean design focused on ease of use
- **Quick Capture**: Fast photo capture with minimal steps
- **Visual Timeline**: Browse your past reminders with thumbnails
- **Statistics Dashboard**: Track your productivity with visual analytics
- **Privacy Focused**: All data stays on your devices
- **Modern UI**: Built with SwiftUI for a native feel

### Advanced Features
- **Photo Management**: Take photos directly or choose from library
- **Overdue Tracking**: Visual indicators for missed reminders
- **Completion Tracking**: Mark reminders as done with visual feedback
- **Time Calculations**: Real-time countdown to reminder time
- **Data Export**: Export your reminders data
- **Settings Management**: Configure app permissions and preferences

## Screenshots

*[Screenshots will be added here]*

## Installation

### iOS
1. Download from the App Store (coming soon)
2. Or build from source (see Development section)

### macOS
1. Download from the Mac App Store (coming soon)
2. Or build from source (see Development section)

## Usage

### Creating a Visual Reminder

1. **Open the App**: Launch VisReminder on your device
2. **Tap the + Button**: In the main reminders list
3. **Add Details**:
   - Enter a title for your reminder
   - Add optional notes for context
   - Set the reminder date and time
4. **Add a Photo**:
   - Tap "Take Photo" to use the camera
   - Tap "Choose Photo" to select from library
5. **Save**: Your visual reminder is now set

### Managing Reminders

- **View All**: Browse your timeline of visual reminders
- **Mark Complete**: Check off reminders you've completed
- **Edit**: Modify reminder times or add notes
- **Delete**: Remove reminders you no longer need
- **Search**: Find specific reminders quickly
- **Filter**: View reminders by status (Active, Overdue, etc.)

### Apple Reminders Integration

- **Automatic Sync**: Reminders are automatically created in Apple Reminders
- **Bidirectional Updates**: Changes sync between VisReminder and Apple Reminders
- **Status Tracking**: See sync status in reminder details
- **Permission Management**: Grant access in Settings tab

### Statistics & Analytics

- **Overview Dashboard**: See total, active, overdue, and completed reminders
- **Recent Activity**: Track your reminder creation patterns
- **Visual Statistics**: Beautiful charts and metrics

## Development

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Apple Developer Account (for App Store distribution)

### Building from Source

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/VisReminder.git
   cd VisReminder
   ```

2. **Open in Xcode**
   ```bash
   open VisReminder.xcodeproj
   ```

3. **Configure Signing**
   - Select your team in the project settings
   - Update bundle identifiers if needed

4. **Build and Run**
   - Select your target device/simulator
   - Press Cmd+R to build and run

### Required Permissions

The app requires the following permissions:

- **Camera Access**: For taking photos
- **Photo Library Access**: For selecting existing photos
- **Reminders Access**: For Apple Reminders integration

These are automatically requested when needed.

### Project Structure

```
VisReminder/
├── VisReminder/
│   ├── VisReminderApp.swift          # App entry point
│   ├── ContentView.swift             # Main tab view
│   ├── ReminderModel.swift           # Data model
│   ├── ReminderStore.swift           # State management
│   ├── ReminderListView.swift        # Main list view
│   ├── ReminderDetailView.swift      # Detail view
│   ├── PhotoCaptureView.swift        # Photo capture
│   └── Assets.xcassets/              # App assets
├── VisReminder.xcodeproj/            # Xcode project
├── build.sh                          # Build script
└── README.md                         # This file
```

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of data, business logic, and UI
- **ObservableObject**: Reactive state management
- **EventKit**: Apple Reminders integration
- **AVFoundation**: Camera functionality
- **Photos Framework**: Photo library access
- **UserDefaults**: Local data persistence

### Key Components

#### Data Model (`ReminderModel.swift`)
```swift
struct VisualReminder: Identifiable, Codable {
    let id = UUID()
    var title: String
    var notes: String
    var photoData: Data?
    var reminderDate: Date
    var isCompleted: Bool = false
    var appleReminderID: String?
    var createdAt: Date = Date()
}
```

#### State Management (`ReminderStore.swift`)
- ObservableObject for reactive UI updates
- CRUD operations for reminders
- Apple Reminders integration
- Local persistence with UserDefaults
- Filtered data access

#### Photo Capture (`PhotoCaptureView.swift`)
- Camera access with permission handling
- Photo library integration
- Image picker with editing capabilities
- Permission request flows

## Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues
- Use the GitHub issue tracker
- Include device info, iOS version, and steps to reproduce
- Add screenshots for UI issues

### Submitting Pull Requests
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Development Guidelines
- Follow Swift style guidelines
- Write unit tests for new features
- Update documentation as needed
- Test on both iOS and macOS

## Roadmap

### Version 1.0 (Current) ✅ COMPLETE
- [x] Photo capture and management
- [x] Time-based reminders
- [x] Apple Reminders integration
- [x] Search and filtering
- [x] Statistics dashboard with productivity trends
- [x] Settings management
- [x] Local notifications with photo attachments
- [x] Export functionality (JSON format)
- [x] Share individual reminders
- [x] Enhanced UI with better empty states

### Version 1.1 (Planned)
- [ ] CloudKit sync
- [ ] Reminder categories/tags
- [ ] Widget support
- [ ] Notification improvements

### Version 1.2 (Future)
- [ ] Location-based reminders
- [ ] Voice notes
- [ ] Sharing reminders
- [ ] Advanced notification options

## Privacy

VisReminder is designed with privacy in mind:
- All data is stored locally on your device
- No data is sent to external servers
- Camera access is only used for taking reminder photos
- You control all permissions
- Apple Reminders integration respects your existing privacy settings

## Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join conversations in GitHub Discussions
- **Email**: Contact us at support@visreminder.app

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and modern iOS frameworks
- Icons from SF Symbols
- Inspired by the need for better visual task management
- Apple Reminders integration for seamless workflow

---

**VisReminder** - Making visual reminders simple and effective.