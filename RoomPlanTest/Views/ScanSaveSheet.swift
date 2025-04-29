// 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
//
// ScanSaveSheet.swift
// RoomPlanTest

import SwiftUI
import SwiftData
import RoomPlan

struct ScanSaveSheet: View {
    var capturedRoom: CapturedRoom
    var onSave: (String, Folder, String?, [String]?) -> Void
    @Query(sort: [SortDescriptor(\Folder.dateCreated, order: .reverse)]) var folders: [Folder]
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var scanName = ""
    @State private var selectedFolder: Folder?
    @State private var newFolderName = ""
    @State private var notes = ""
    @State private var tagsString = ""
    @State private var creatingNewFolder = false
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Scan Name")) {
                    TextField("e.g. Living Room", text: $scanName)
                }
                Section(header: Text("Folder")) {
                    Picker("Folder", selection: $selectedFolder) {
                        ForEach(folders) { folder in
                            Text(folder.name).tag(Optional(folder))
                        }
                        Text("+ New Folder").tag(Optional<Folder>.none)
                    }
                    if selectedFolder == nil {
                        TextField("New Folder Name", text: $newFolderName)
                    }
                }
                Section(header: Text("Notes (optional)")) {
                    TextField("Notes", text: $notes)
                }
                Section(header: Text("Tags (comma separated, optional)")) {
                    TextField("Tags", text: $tagsString)
                }
            }
            .navigationTitle("Save Scan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let folder: Folder
                        if let sel = selectedFolder {
                            folder = sel
                        } else {
                            folder = Folder(name: newFolderName.isEmpty ? "New Folder" : newFolderName)
                            modelContext.insert(folder)
                        }
                        let tags = tagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        onSave(scanName, folder, notes.isEmpty ? nil : notes, tags.isEmpty ? nil : tags)
                        dismiss()
                    }
                    .disabled(scanName.trimmingCharacters(in: .whitespaces).isEmpty || (selectedFolder == nil && newFolderName.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
        }
    }
}
