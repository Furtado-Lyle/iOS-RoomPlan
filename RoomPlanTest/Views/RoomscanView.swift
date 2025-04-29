// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
//
//  RoomscanView.swift
//  RoomPlanTest
//
//  Created by Lyle Furtado on 29/04/25.
//
import SwiftUI
import RoomPlan

/// A SwiftUI view that manages the room scanning process using RoomPlan.
/// - Handles scanning, preview, export, and completion callbacks.
import SwiftData
import UIKit

struct RoomscanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var capturedRoom: CapturedRoom?
    @State private var showingSaveSheet = false
    @State private var scanningViewRef: RoomCaptureRepresentableRef? = nil
    /// Completion handler called when scan is saved (returns Scan).
    var onScanSaved: (Scan) -> Void
    var body: some View {
        ZStack {
            // Single view that handles both scanning and preview
            RoomCaptureRepresentable(
                reference: $scanningViewRef,
                onScanComplete: { capturedRoom in
                    self.capturedRoom = capturedRoom
                    self.showingSaveSheet = true
                },
                onCancel: {
                    dismiss()
                }
            )
            .ignoresSafeArea()
            .overlay(
                VStack {
                    HStack {
                        Button("Cancel") { dismiss() }
                            .padding()
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.white)
                            .background(Color.clear)
                        Spacer()
                        // Show Done or Export button based on state
                        if capturedRoom == nil {
                            Button("Done") {
                                if let scanningViewRef = scanningViewRef {
                                    scanningViewRef.finishScanning()
                                }
                            }
                            .padding()
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.clear)
                            .fontWeight(Font.Weight.bold)
                        } else {
                            Button("Save") { showingSaveSheet = true }
                                .padding()
                                .buttonStyle(PlainButtonStyle())
                                .background(Color.clear)
                                .fontWeight(Font.Weight.bold)
                        }
                    }
                    .padding(.top)
                    Spacer()
                }
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSaveSheet) {
            if let capturedRoom = capturedRoom {
                ScanSaveSheet(capturedRoom: capturedRoom) { scanName, folder, notes, tags in
                    // Save USDZ file
                    let fileName = UUID().uuidString + ".usdz"
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let usdzURL = docs.appendingPathComponent(fileName)
                    do {
                        try capturedRoom.export(to: usdzURL)
                        // Generate and save thumbnail
                        let thumbnailImage = ScanThumbnailGenerator.generateThumbnail(for: capturedRoom)
                        var thumbnailFileName: String? = nil
                        if let image = thumbnailImage, let data = image.pngData() {
                            let thumbName = UUID().uuidString + ".png"
                            let thumbURL = docs.appendingPathComponent(thumbName)
                            try? data.write(to: thumbURL)
                            thumbnailFileName = thumbName
                        }
                        let scan = Scan(name: scanName, usdzFileName: fileName, folder: folder, thumbnailFileName: thumbnailFileName, roomSize: nil, notes: notes, tags: tags)
                        @Environment(\.modelContext) var modelContext
                        modelContext.insert(scan)
                        onScanSaved(scan)
                    } catch {
                        print("Failed to save scan: \(error)")
                    }
                }
            }
        }
    }
    
    
    
    
    // A share sheet to export the USDZ file
    struct ShareSheet: UIViewControllerRepresentable {
        var items: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
            return controller
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
            // Nothing to update
        }
    }
    
    // A reference class to control the RoomCaptureView from outside
    class RoomCaptureRepresentableRef {
        var captureView: RoomCaptureView?
        func finishScanning() {
            captureView?.captureSession.stop()
        }
    }
    
    // A UIViewRepresentable for RoomCaptureView
    struct RoomCaptureRepresentable: UIViewRepresentable {
        @Binding var reference: RoomCaptureRepresentableRef?
        var onScanComplete: (CapturedRoom) -> Void
        var onCancel: () -> Void
        
        func makeUIView(context: Context) -> RoomCaptureView {
            let roomCaptureView = RoomCaptureView(frame: .zero)
            roomCaptureView.delegate = context.coordinator
            
            // Create and assign the reference
            let ref = RoomCaptureRepresentableRef()
            ref.captureView = roomCaptureView
            self.reference = ref
            
            // Create a mutable configuration
            var configuration = RoomCaptureSession.Configuration()
            configuration.isCoachingEnabled = true
            
            // Start the session when the view is created
            roomCaptureView.captureSession.run(configuration: configuration)
            
            return roomCaptureView
        }
        
        func updateUIView(_ uiView: RoomCaptureView, context: Context) {
            // No updates needed
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
        
        // This is important for cleanup
        static func dismantleUIView(_ uiView: RoomCaptureView, coordinator: Coordinator) {
            uiView.captureSession.stop()
        }
        
        // Implement NSCoding for Coordinator
        @objc(RoomCaptureCoordinator) class Coordinator: NSObject, RoomCaptureViewDelegate, NSCoding {
            var parent: RoomCaptureRepresentable
            
            init(parent: RoomCaptureRepresentable) {
                self.parent = parent
                super.init()
            }
            
            // NSCoding implementation
            required init?(coder: NSCoder) {
                fatalError("Coordinator doesn't support NSCoding")
            }
            
            func encode(with coder: NSCoder) {
                // Nothing to encode
            }
            
            // Process the room data and handle results
            func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
                // Return true to let RoomCaptureView process the data
                return true
            }
            
            // Handle the processed result
            func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
                if let error = error {
                    print("Error processing room: \(error.localizedDescription)")
                    return
                }
                
                parent.onScanComplete(processedResult)
            }
        }
    }
}
