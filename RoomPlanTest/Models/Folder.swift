// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
// Folder.swift
// RoomPlanTest

import Foundation
import SwiftData

@Model
final class Folder: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var dateCreated: Date
    var scans: [Scan] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.dateCreated = Date()
        self.scans = []
    }
}
