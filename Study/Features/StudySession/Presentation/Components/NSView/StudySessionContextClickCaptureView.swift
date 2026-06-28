//
//  StudySessionContextClickCaptureView.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import AppKit
import SwiftUI

struct StudySessionContextClickCaptureView: NSViewRepresentable {
    let onContextClick: () -> Void

    func makeNSView(context: Context) -> StudySessionContextClickNSView {
        let view = StudySessionContextClickNSView()
        view.onContextClick = onContextClick
        return view
    }

    func updateNSView(_ nsView: StudySessionContextClickNSView, context: Context) {
        nsView.onContextClick = onContextClick
    }
}

final class StudySessionContextClickNSView: NSView {
    var onContextClick: (() -> Void)?

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let event = NSApp.currentEvent else { return nil }

        switch event.type {
        case .rightMouseDown, .rightMouseUp:
            return self
        case .leftMouseDown where event.modifierFlags.contains(.control):
            return self
        case .leftMouseUp where event.modifierFlags.contains(.control):
            return self
        default:
            return nil
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        onContextClick?()
    }

    override func mouseDown(with event: NSEvent) {
        guard event.modifierFlags.contains(.control) else {
            super.mouseDown(with: event)
            return
        }

        onContextClick?()
    }
}
