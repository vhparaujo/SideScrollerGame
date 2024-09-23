//
//  ModelContext.swift
//  SideScrollerGame
//
//  Created by Eduardo on 20/09/24.
//

import SwiftData

extension ModelContainer {
    
    static let appContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: KeymapModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
            return container
        } catch {
            fatalError("Could not load model container: \(error)")
        }
    }()
    
}
