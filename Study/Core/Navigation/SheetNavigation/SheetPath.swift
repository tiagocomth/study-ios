//
//  SheetPath.swift
//  Challenge13
//
//  Created by Caio Mandarino on 02/04/26.
//

import Foundation

struct SheetPath: Identifiable {
    var id: String { sheet?.id ?? UUID().uuidString }
    var sheet: SheetContainer?
    
    mutating func setSheet<T>(_ sheet: T, onDismiss: (() -> Void)? = nil) where T: Identifiable & Hashable {
        self.sheet = SheetContainer(sheet: sheet, onDismiss: onDismiss)
    }
}

struct SheetContainer: Identifiable {
    let id: String
    let sheet: Any
    let onDismiss: (() -> Void)?
    
    init<T>(sheet: T, onDismiss: (() -> Void)? = nil) where T: Identifiable & Hashable {
        self.id = String(describing: T.self)
        self.sheet = sheet
        self.onDismiss = onDismiss
    }
}
