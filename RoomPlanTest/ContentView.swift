// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
//
//  ContentView.swift
//  RoomPlanTest
//
//  Created by Lyle Furtado on 29/04/25.
//

import SwiftUI
import RoomPlan
import ARKit

/// The main entry view for RoomPlanTest.
/// - Shows UI for starting a room scan, device compatibility, and handles scan results.
struct ContentView: View {
    var body: some View {
        TabView {
            ScanTabView()
                .tabItem {
                    Label("Scan", systemImage: "plus.viewfinder")
                }
            SavedRoomsView()
                .tabItem {
                    Label("Saved Rooms", systemImage: "folder")
                }
        }
    }
}

struct ScanTabView: View {
    @State private var showingScanner = false
    @State private var capturedRoom: CapturedRoom?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var lastSavedScan: Scan?
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                if !isDeviceSupported() {
                    // Warning for non-LiDAR devices
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                        Text("Room scanning is not available on this device.\nA LiDAR sensor is required for 3D scanning.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding()
                } else  {
                    VStack {
                        Image("AppIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Text("Welcome to RoomScan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                            .multilineTextAlignment(.center)
                        Text("Easily scan your room and export a 3D model. Tap the + button to begin scanning.")
                            .font(.subheadline)
                            .foregroundColor(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        checkCameraPermission { granted in
                            if granted {
                                showingScanner = true
                            } else {
                                alertMessage = "RoomScan needs access to your camera to scan rooms. Please enable camera access in Settings."
                                showingAlert = true
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                NavigationStack {
                    RoomscanView { scan in
                        // Scan saved callback
                        self.lastSavedScan = scan
                        self.alertMessage = "Scan saved successfully!"
                        self.showingAlert = true
                        self.showingScanner = false
                    }
                }
            }
            .alert("Notice", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    /// Checks if the current device supports RoomPlan (requires LiDAR sensor).
    private func isDeviceSupported() -> Bool {
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            return true
        }
        return false
    }
    /// Checks camera permission and calls the completion handler with the result.
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}


#Preview {
    ContentView()
}
