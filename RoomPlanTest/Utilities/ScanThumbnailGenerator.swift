// © 2025 Lyle Furtado
// CC0 1.0 Universal Public Domain Dedication
// https://creativecommons.org/publicdomain/zero/1.0/
// “This code is in the public domain. Attribution is appreciated, but not required.”
// ScanThumbnailGenerator.swift
// RoomPlanTest

import Foundation
import UIKit
import RoomPlan

struct ScanThumbnailGenerator {
    static func generateThumbnail(for capturedRoom: CapturedRoom, size: CGSize = CGSize(width: 256, height: 256)) -> UIImage? {
        // RoomPlan does not provide a direct thumbnail API. We'll render a top-down orthographic view as a placeholder.
        // For a real app, you might use SceneKit/RealityKit to render the USDZ, but here we just use a colored rectangle as a stub.
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.systemGray.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 32),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]
            let text = "Room"
            let textRect = CGRect(x: 0, y: size.height/2 - 20, width: size.width, height: 40)
            text.draw(in: textRect, withAttributes: attrs)
        }
        return image
    }
}
