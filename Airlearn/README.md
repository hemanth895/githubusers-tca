
# GitHub Users App

A modern iOS application built with The Composable Architecture (TCA) that allows users to browse and search GitHub users.

## Features

- 🔍 Search GitHub users by username
- 👥 Browse a list of GitHub users
- 📱 Clean, modern SwiftUI interface
- 🏗️ Built with The Composable Architecture for predictable state management
- 📊 User profile details and statistics
- 🌐 Real-time data fetching from GitHub API

## Screenshots

<!-- Add screenshots here -->

## Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **The Composable Architecture (TCA)** - Unidirectional data flow architecture
- **Combine** - Reactive programming framework
- **URLSession** - Network requests
- **GitHub API** - User data source

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/airlearn.git
cd airlearn
```

2. Open the project in Xcode:
```bash
open Airlearn.xcodeproj
```

3. Build and run the project in Xcode or use the command line:
```bash
xcodebuild -scheme Airlearn -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Architecture

This app follows The Composable Architecture principles:

- **State**: All app state is held in simple data types
- **Actions**: State changes are expressed as actions
- **Reducers**: Pure functions that evolve state based on actions
- **Effects**: Handle side effects like API calls
- **Environment**: Dependencies injection for testability

### Project Structure

```
Airlearn/
├── App/
│   ├── AirlearnApp.swift
│   └── ContentView.swift
├── Features/
│   ├── UserList/
│   │   ├── UserListView.swift
│   │   ├── UserListCore.swift
│   │   └── UserListRow.swift
│   ├── UserDetail/
│   │   ├── UserDetailView.swift
│   │   └── UserDetailCore.swift
│   └── Search/
│       ├── SearchView.swift
│       └── SearchCore.swift
├── Models/
│   ├── GitHubUser.swift
│   └── UserDetail.swift
├── Services/
│   ├── GitHubAPI.swift
│   └── NetworkClient.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## Usage

1. **Browse Users**: Launch the app to see a list of GitHub users
2. **Search**: Use the search bar to find specific users by username
3. **View Details**: Tap on any user to see their profile details
4. **Refresh**: Pull down to refresh the user list

## API Integration

The app integrates with the GitHub REST API v3:

- **Users endpoint**: `https://api.github.com/users`
- **User details**: `https://api.github.com/users/{username}`
- **Search users**: `https://api.github.com/search/users?q={query}`

## Testing

Run the test suite:

```bash
xcodebuild test -scheme Airlearn -destination 'platform=iOS Simulator,name=iPhone 15'
```

The app includes:
- Unit tests for reducers
- Integration tests for API calls
- UI tests for critical user flows

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code Style

This project follows:
- Swift API Design Guidelines
- SwiftLint rules for code consistency
- TCA best practices and conventions

## Dependencies

- [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) - The Composable Architecture framework

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


---

Made with ❤️ using SwiftUI and The Composable Architecture
