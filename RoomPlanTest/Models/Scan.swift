// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
// Scan.swift
// RoomPlanTest

import Foundation
import SwiftData

@Model
final class Scan: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var dateCreated: Date
    var usdzFileName: String // Path in Documents directory
    var thumbnailFileName: String? // Path in Documents directory
    var roomSize: String? // Could be more structured
    var notes: String?
    var tags: [String]?
    @Relationship(deleteRule: .nullify, inverse: \Folder.scans) var folder: Folder?
    
    init(name: String, usdzFileName: String, folder: Folder? = nil, thumbnailFileName: String? = nil, roomSize: String? = nil, notes: String? = nil, tags: [String]? = nil) {
        self.id = UUID()
        self.name = name
        self.dateCreated = Date()
        self.usdzFileName = usdzFileName
        self.thumbnailFileName = thumbnailFileName
        self.roomSize = roomSize
        self.notes = notes
        self.tags = tags
        self.folder = folder
    }
}
