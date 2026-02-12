# Flutter Todo App

A beautiful and functional Todo application built with Flutter, featuring local data persistence with Hive, smooth animations, and an intuitive user interface.

## Features

- ✅ Create, read, update, and delete tasks
- 📅 Add date and time to tasks
- ✨ Mark tasks as completed
- 🗑️ Swipe to delete tasks
- 🎨 Beautiful gradient UI with smooth animations
- 💾 Local data persistence using Hive
- 📱 Responsive design
- 🎭 Lottie animations for empty states
- 🔄 Real-time task updates

## Technologies Used

- **Flutter** - UI framework
- **Hive** - Lightweight and fast NoSQL database for local storage
- **Lottie** - For engaging animations
- **Intl** - For date and time formatting
- **Animate Do** - For smooth UI animations
- **Panara Dialogs** - For beautiful dialog boxes
- **Flutter Slider Drawer** - For the navigation drawer

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd to_do
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Enable Developer Mode on Windows (for Windows development):

   ```bash
   start ms-settings:developers
   ```

4. Run the app:

   ```bash
   # For Chrome
   flutter run -d chrome

   # For Windows
   flutter run -d windows

   # For other devices
   flutter devices
   flutter run -d <device-id>
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart            # Task model with Hive annotations
├── data/
│   └── hive_data_store.dart # Hive database operations
├── utils/
│   ├── colors.dart          # App color constants
│   ├── constanst.dart       # Utility functions
│   └── strings.dart         # String constants
└── view/
    ├── home/
    │   ├── home_view.dart   # Main home screen
    │   └── widgets/
    │       └── task_widget.dart  # Individual task widget
    └── tasks/
        └── task_view.dart   # Task creation/edit screen
```

## Key Features Explained

### Task Management

- Create tasks with title, subtitle, date, and time
- Edit existing tasks
- Mark tasks as complete/incomplete
- Delete tasks with swipe gesture

### Data Persistence

- Uses Hive for fast local storage
- Tasks persist between app sessions
- Real-time updates with ValueListenableBuilder

### UI/UX

- Material Design 3 support
- Custom color gradients
- Lottie animations for empty states
- Smooth page transitions
- Interactive drawer navigation

## Troubleshooting

### Common Issues

1. **Asset directory error**: Ensure `assets/img/` and `assets/lottie/` directories exist
2. **Hive initialization error**: Make sure Hive is properly initialized in `main.dart`
3. **Build errors**: Run `flutter clean` and `flutter pub get`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Lottie Files](https://lottiefiles.com/)
