// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
//
//  RoomPlanTestApp.swift
//  RoomPlanTest
//
//  Created by Lyle Furtado on 29/04/25.
//

import SwiftUI
import SwiftData

/// RoomPlanTestApp is the main entry point for the RoomPlanTest application.
///
/// This app allows users to scan rooms using LiDAR, save 3D room scans with metadata, organize them into folders, and manage them using a clean SwiftUI interface.
///
/// The SwiftData ModelContainer is configured to persist Items, Folders, and Scans, enabling robust scan and folder management across app launches.
@main
struct RoomPlanTestApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Folder.self,
            Scan.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
