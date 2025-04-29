# 📱 RoomPlanTest

RoomPlanTest is a SwiftUI-based iOS app that leverages Apple’s RoomPlan and SwiftData frameworks to scan rooms in 3D, organize scans into folders, and manage them with rich metadata.

---

## 💫 Features

- **Room Scanning**  
  Use LiDAR-enabled devices to scan and capture 3D rooms as USDZ files.  
- **Scan Management**  
  Save scans with custom names, notes, and tags, then organize them into folders.  
- **Folder Organization**  
  Create, rename, and delete folders to keep scans neatly organized.  
- **Thumbnails**  
  Automatically generate and display thumbnails for each scan.  
- **QuickLook Preview**  
  Preview 3D scans directly in the app using QuickLook.  
- **Export & Share**  
  Share USDZ files via the system share sheet.

---

## 💻 Technologies Used

- **SwiftUI** for a modern, declarative interface  
- **SwiftData** for local data persistence  
- **RoomPlan** for 3D room capture and processing  
- **QuickLook** for in-app 3D file preview

---

## ⚙️ Requirements

- iOS 17+  
- Xcode 15+  
- Device with LiDAR sensor (for scanning)

---

## 🏁 Getting Started

1. **Clone** the repo.  
2. **Open** `RoomPlanTest.xcodeproj` in Xcode.  
3. **Build & run** on a LiDAR-enabled device.

---

## 🏗️ Project Structure

- **`RoomPlanTestApp.swift`** — App entry point & SwiftData setup  
- **`ContentView.swift`** — Main tabbed interface  
- **`RoomscanView.swift`** — Scanning UI & logic  
- **`SavedRoomsView.swift`** — Scan/folder management UI  
- **`Models/`** — SwiftData models (`Scan`, `Folder`)  
- **`ScanSaveSheet.swift`** — Sheet for entering scan metadata  
- **`ScanThumbnailGenerator.swift`** — Thumbnail generation logic  

---

## 🎥 Screen Rec
Recordings demonstrating the core flows of the app.

| Room Plan Scan                                                                 | View Scanned Model                                                                |
|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| ![IMG_3650](https://github.com/user-attachments/assets/a2595070-f982-44db-8c0d-8bf32b875380) | ![IMG_3651](https://github.com/user-attachments/assets/562a8c3a-2aa0-4714-bbfb-5919bb17d000)

---

## 📸  Screen Shots
Still captures to illustrate UI elements in action.

| Room Plan Scan                                                  | View Scanned Model                                       |
|-----------------------------------------------------------------|----------------------------------------------------------|
| ![1](https://github.com/user-attachments/assets/9bf47223-66e4-4c61-b5d5-95e03c621046)| ![2](https://github.com/user-attachments/assets/fe8dac72-cd89-4285-8d67-d96e8c2e94d4)|


---

## 👮‍♂️ License

MIT License

---

*Created by Lyle Furtado, 2025.*  
