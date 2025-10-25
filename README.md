# Sneaker Storekeeper 👟

A modern mobile inventory management application for tracking sneaker stock, built with Flutter and Hive local database.

## Features ✨

- **CRUD Operations**: Create, Read, Update, and Delete sneaker inventory
- **Local Storage**: Data persists using Hive (NoSQL database)
- **Image Management**: Capture or select sneaker photos from camera/gallery
- **Search & Filter**: Find sneakers by name or brand
- **Sort Options**: Sort by date, name, or price
- **Inventory Statistics**: View total value and low stock alerts
- **Responsive UI**: Clean, modern purple-themed interface

## Technologies Used 🛠️

- **Flutter**: Cross-platform mobile framework
- **Hive**: Fast, lightweight local database
- **Image Picker**: Camera and gallery integration
- **Material Design 3**: Modern UI components

## Project Structure 📁
```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── sneaker.dart              # Sneaker data model
│   └── sneaker.g.dart            # Generated Hive adapter
├── services/
│   └── database_service.dart     # Database operations (CRUD)
├── screens/
│   ├── home_screen.dart          # Main inventory screen
│   ├── add_sneaker_screen.dart   # Add new sneaker form
│   └── sneaker_detail_screen.dart # View/Edit sneaker details
└── widgets/
    └── sneaker_card.dart         # Reusable sneaker card widget
```

## Database Schema 💾

### Sneaker Model
- `name`: String - Sneaker name
- `brand`: String - Brand name  
- `price`: Double - Sneaker price
- `quantity`: Integer - Stock quantity
- `imagePath`: String? - Path to sneaker image (optional)
- `description`: String? - Product description (optional)
- `dateAdded`: DateTime - Timestamp when added

## Setup & Installation 🚀

### Prerequisites
- Flutter SDK (3.35.6 or higher)
- Dart SDK
- Windows/Android/iOS development tools

### Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd sneaker_storekeeper
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters**
```bash
flutter pub run build_runner build
```

4. **Run the app**
```bash
# For Windows Desktop
flutter run -d windows

# For Android
flutter run -d <device-id>

# For iOS
flutter run -d <device-id>
```
## First Launch Experience 🎯

The app comes pre-loaded with 6 sample sneakers to demonstrate functionality:
- Air Jordan 4 Retro Fire Red
- Nike Air Max Moto 2K Womens  
- Air Jordan 1 Mid SE
- Jordan Luka.77
- Adidas Originals ZX750
- New Balance 740

Users can:
- View these sample items
- Add their own sneakers
- Edit or delete any item
- All data persists locally using Hive database

**Note**: Sample data only appears on first launch when database is empty.


## Usage Guide 📖

### Adding a Sneaker
1. Tap the "Add Sneaker" floating button
2. Tap image area to add photo (camera/gallery)
3. Fill in sneaker details (name, brand, price, quantity)
4. Tap "Save Sneaker"

### Viewing Details
1. Tap any sneaker card from the home screen
2. View full details and image
3. Tap image to view full-size (mobile/desktop only)

### Editing a Sneaker
1. Open sneaker details
2. Tap the edit icon (top right)
3. Modify fields as needed
4. Tap "Save Changes"

### Deleting a Sneaker
1. Tap the delete icon on sneaker card
2. Confirm deletion in dialog

### Searching
1. Use the search bar at the top
2. Type sneaker name or brand
3. Results filter in real-time

### Sorting
1. Tap the sort icon (top right)
2. Choose: Recent, Name, Price Low, or Price High

## Key Features Explained 🔑

### CRUD Operations
- **Create**: Add new sneakers with all details
- **Read**: View all sneakers and individual details
- **Update**: Edit existing sneaker information
- **Delete**: Remove sneakers with confirmation

### Local Storage
- Uses Hive for fast, efficient local storage
- Data persists between app sessions
- No internet connection required

### Image Handling
- Take photos with device camera
- Select from photo gallery
- Images stored permanently in app directory
- Remove/replace images anytime

### Low Stock Alerts
- Automatically highlights sneakers with quantity < 5
- Shows count in statistics panel

## Platform Support 💻

- ✅ Windows Desktop (Full support)
- ✅ Android (Full support)
- ✅ iOS (Full support)
- ⚠️ Web (Limited - no file system access for images)

## Dependencies 📦
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  image_picker: ^1.0.7
  path_provider: ^2.1.2
  path: ^1.8.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```





## Author 👨‍💻

Created for HNG Internship - Mobile Track Stage 2

## License 📄

This project is created for educational purposes as part of the HNG Internship program.

## Acknowledgments 🙏

- HNG Internship Program
- Flutter Community
- Hive Database Team
