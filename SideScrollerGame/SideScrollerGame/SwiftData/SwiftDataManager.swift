//
//  SwiftDataManager.swift
//  SideScrollerGame
//
//  Created by Eduardo on 23/09/24.
//

import Foundation
import SwiftData
import SwiftUI

// SwiftDataManager: Manages SwiftData operations for specific models
@MainActor
class SwiftDataManager {
    
    static let shared = SwiftDataManager()
    
    private let container: ModelContainer
    
    private init(container: ModelContainer = .testContainer) {
        // Initialize the SwiftData model container with all relevant models
        self.container = container
    }
    
    // Provide access to the main context for performing operations
    var context: ModelContext {
        return container.mainContext
    }
    
    // MARK: - KeymapModel Operations
    
    // Fetch all KeymapModels
    func fetchAllKeymaps() -> [KeymapModel]? {
        let fetchRequest = FetchDescriptor<KeymapModel>()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch keymaps: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Fetch the first KeymapModel
    func fetchFirstKeymap() -> KeymapModel? {
        return fetchAllKeymaps()?.first
    }
    
    // Insert a new KeymapModel
    func insertKeymap(_ keymap: KeymapModel) {
        context.insert(keymap)
        saveContext()
    }
    
    // Update a KeymapModel
    func updateKeymap(_ keymap: KeymapModel, changes: (KeymapModel) -> Void) {
        changes(keymap)
        saveContext()
    }
    
    // Delete a KeymapModel
    func deleteKeymap(_ keymap: KeymapModel) {
        context.delete(keymap)
        saveContext()
    }
    
    // MARK: - Common Save Context
    
    // Save the current context state
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
