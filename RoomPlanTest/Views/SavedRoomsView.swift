// 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
//
//  SavedRoomsView.swift
// RoomPlanTest

import SwiftUI
import SwiftData

struct SavedRoomsView: View {
    @Query(sort: [SortDescriptor(\Folder.dateCreated, order: .reverse)]) var folders: [Folder]
    @State private var searchText = ""
    @State private var showingNewFolderSheet = false
    @State private var showingRenameFolderSheet = false
    @State private var folderToRename: Folder?
    @State private var selectedFolder: Folder?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredFolders) { folder in
                    NavigationLink(destination: FolderDetailView(folder: folder)) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading) {
                                Text(folder.name)
                                    .font(.headline)
                                Text("\(folder.scans.count) rooms")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                folderToRename = folder
                                showingRenameFolderSheet = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .onDelete(perform: deleteFolders)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search rooms or folders")
            .navigationTitle("Saved Rooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewFolderSheet = true }) {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewFolderSheet) {
                NewFolderSheet(isPresented: $showingNewFolderSheet)
            }
            .sheet(isPresented: $showingRenameFolderSheet) {
                if let folder = folderToRename {
                    RenameFolderSheet(isPresented: $showingRenameFolderSheet, folder: folder)
                }
            }
        }
    }
    
    var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        } else {
            return folders.filter { folder in
                folder.name.localizedCaseInsensitiveContains(searchText) ||
                folder.scans.contains { $0.name.localizedCaseInsensitiveContains(searchText) || ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false) }
            }
        }
    }
    
    @Environment(\.modelContext) var modelContext
    func deleteFolders(at offsets: IndexSet) {
        for index in offsets {
            let folder = folders[index]
            modelContext.delete(folder)
        }
    }
    
    func deleteScans(indices: IndexSet, in folder: Folder) {
        for index in indices {
            let scan = folder.scans.sorted { $0.dateCreated > $1.dateCreated }[index]
            modelContext.delete(scan)
        }
    }
}

struct NewFolderSheet: View {
    @Binding var isPresented: Bool
    @State private var folderName = ""
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Folder Name")) {
                    TextField("e.g. House A", text: $folderName)
                }
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !folderName.trimmingCharacters(in: .whitespaces).isEmpty {
                            let folder = Folder(name: folderName)
                            modelContext.insert(folder)
                            isPresented = false
                        }
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct FolderDetailView: View {
    @Bindable var folder: Folder
    @State private var showingRenameScanSheet = false
    @State private var scanToRename: Scan?
    @State private var showingMoveScanSheet = false
    @State private var scanToMove: Scan?
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var body: some View {
        List {
            ForEach(folder.scans.sorted { $0.dateCreated > $1.dateCreated }) { scan in
                NavigationLink(destination: ScanDetailView(scan: scan)) {
                    HStack {
                        if let thumb = scan.thumbnailFileName {
                            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let thumbURL = docs.appendingPathComponent(thumb)
                            if let uiImage = UIImage(contentsOfFile: thumbURL.path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(8)
                            }
                        } else {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                        }
                        VStack(alignment: .leading) {
                            Text(scan.name)
                                .font(.headline)
                            Text(scan.dateCreated, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let notes = scan.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button(action: {
                            scanToRename = scan
                            showingRenameScanSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            scanToMove = scan
                            showingMoveScanSheet = true
                        }) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .onDelete { indices in
                deleteScans(indices: indices)
            }
        }
        .navigationTitle(folder.name)
        .sheet(isPresented: $showingRenameScanSheet) {
            if let scan = scanToRename {
                RenameScanSheet(isPresented: $showingRenameScanSheet, scan: scan)
            }
        }
        .sheet(isPresented: $showingMoveScanSheet) {
            if let scan = scanToMove {
                MoveScanSheet(isPresented: $showingMoveScanSheet, scan: scan, currentFolder: folder)
            }
        }
    }
    
    func deleteScans(indices: IndexSet) {
        for index in indices {
            let scan = folder.scans.sorted { $0.dateCreated > $1.dateCreated }[index]
            modelContext.delete(scan)
        }
    }
}

struct RenameFolderSheet: View {
    @Binding var isPresented: Bool
    @Bindable var folder: Folder
    @State private var folderName: String = ""
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rename Folder")) {
                    TextField("Folder Name", text: $folderName)
                }
            }
            .navigationTitle("Rename Folder")
            .onAppear { folderName = folder.name }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !folderName.trimmingCharacters(in: .whitespaces).isEmpty {
                            folder.name = folderName
                            do {
                                try modelContext.save()
                                isPresented = false
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        }
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct RenameScanSheet: View {
    @Binding var isPresented: Bool
    @Bindable var scan: Scan
    @State private var scanName: String = ""
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rename Scan")) {
                    TextField("Scan Name", text: $scanName)
                }
            }
            .navigationTitle("Rename Scan")
            .onAppear { scanName = scan.name }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !scanName.trimmingCharacters(in: .whitespaces).isEmpty {
                            scan.name = scanName
                            do {
                                try modelContext.save()
                                isPresented = false
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        }
                    }
                    .disabled(scanName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct MoveScanSheet: View {
    @Binding var isPresented: Bool
    @Bindable var scan: Scan
    var currentFolder: Folder
    @Query(sort: [SortDescriptor(\Folder.dateCreated, order: .reverse)]) var folders: [Folder]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(folders.filter { $0.id != currentFolder.id }) { folder in
                    Button(action: {
                        moveToFolder(folder)
                    }) {
                        Text(folder.name)
                    }
                }
            }
            .navigationTitle("Move Scan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    private func moveToFolder(_ folder: Folder) {
        scan.folder = folder
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error moving scan: \(error)")
        }
    }
}

import QuickLook

struct ScanDetailView: View {
    let scan: Scan
    @State private var showingShare = false
    @State private var showingQuickLook = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Thumbnail
                if let thumb = scan.thumbnailFileName {
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let thumbURL = docs.appendingPathComponent(thumb)
                    if let uiImage = UIImage(contentsOfFile: thumbURL.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .cornerRadius(12)
                            .padding(.bottom, 8)
                    }
                }
                // Metadata
                Text(scan.name)
                    .font(.title2).bold()
                Text("Date: \(scan.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let notes = scan.notes, !notes.isEmpty {
                    Text("Notes: \(notes)")
                        .font(.body)
                }
                if let tags = scan.tags, !tags.isEmpty {
                    Text("Tags: \(tags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let roomSize = scan.roomSize {
                    Text("Room Size: \(roomSize)")
                        .font(.caption)
                }
                // USDZ Preview
                if !scan.usdzFileName.isEmpty {
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let usdzURL = docs.appendingPathComponent(scan.usdzFileName)
                    Button(action: { showingQuickLook = true }) {
                        Label("Preview 3D Room", systemImage: "cube")
                    }
                    .padding(.vertical)
                    .quickLookPreview($showingQuickLook, url: usdzURL)
                    Button(action: { showingShare = true }) {
                        Label("Export / Share", systemImage: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $showingShare) {
                        ShareSheet(items: [usdzURL])
                    }
                }
            }
            .padding()
        }
        .navigationTitle(scan.name)
    }
}

// UIKit ShareSheet helper for export/share
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Helper for QuickLook preview
struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    func updateUIViewController(_ controller: QLPreviewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { url as QLPreviewItem }
    }
}

// SwiftUI modifier for QuickLook
extension View {
    func quickLookPreview(_ isPresented: Binding<Bool>, url: URL) -> some View {
        background(QuickLookPresenter(isPresented: isPresented, url: url))
    }
}

struct QuickLookPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let url: URL
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ controller: UIViewController, context: Context) {
        if isPresented && controller.presentedViewController == nil {
            let ql = QLPreviewController()
            ql.dataSource = context.coordinator
            controller.present(ql, animated: true) {
                isPresented = false
            }
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { url as QLPreviewItem }
    }
}
