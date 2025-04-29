# RoomPlanTest

RoomPlanTest is a SwiftUI-based iOS application that leverages Apple's RoomPlan and SwiftData frameworks to enable users to scan rooms in 3D, organize scans into folders, and manage them with rich metadata.

## Features
- **Room Scanning:** Use LiDAR-enabled devices to scan and capture 3D rooms as USDZ files.
- **Scan Management:** Save scans with custom names, notes, tags, and organize them into folders.
- **Folder Organization:** Create, rename, and delete folders to keep scans organized.
- **Thumbnails:** Automatically generate and display thumbnails for each scan.
- **QuickLook Preview:** Preview 3D scans directly in the app using QuickLook.
- **Export & Share:** Share USDZ files via the system share sheet.

## Technologies Used
- **SwiftUI** for the modern, declarative user interface.
- **SwiftData** for local data persistence and management.
- **RoomPlan** for 3D room capture and processing.
- **QuickLook** for in-app 3D file preview.

## Requirements
- iOS 17+
- Xcode 15+
- Device with LiDAR sensor for 3D scanning features.

## Getting Started
1. Clone the repository.
2. Open `RoomPlanTest.xcodeproj` in Xcode.
3. Build and run on a compatible device.

## Project Structure
- `RoomPlanTestApp.swift`: App entry point and SwiftData setup.
- `ContentView.swift`: Main tabbed interface.
- `RoomscanView.swift`: Scanning UI and logic.
- `SavedRoomsView.swift`: Scan and folder management UI.
- `Models/`: SwiftData models for Scan and Folder.
- `ScanSaveSheet.swift`: Sheet for saving scan metadata.
- `ScanThumbnailGenerator.swift`: Thumbnail generation logic.

## License
MIT License

---

*Created by Lyle Furtado, 2025.*
