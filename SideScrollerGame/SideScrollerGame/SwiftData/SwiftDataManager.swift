//
//  SwiftDataManager.swift
//  SideScrollerGame
//
//  Created by Eduardo on 20/09/24.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable class SwiftDataManager {
    
    var conteiner: ModelContainer
    
    init(conteiner: ModelContainer) {
        self.conteiner = conteiner
    }
    
    func save() {
        do {
            try conteiner.mainContext.save()
        } catch {
            fatalError("Error saving context: \(error)")
        }
    }
    
    func createFetchDescriptor<T: Codable>(
        predicate: Predicate<T>? = nil,
        sortDescriptors: [SortDescriptor<T>] = []
    ) -> FetchDescriptor<T> {
        FetchDescriptor<T>(predicate: predicate, sortBy: sortDescriptors)
    }

    func fetch<T: Codable>(_ fetchDescriptor: FetchDescriptor<T>) -> [T] {
        do {
            return try conteiner.mainContext.fetch(fetchDescriptor)
        } catch {
            fatalError("Fetch error: \(error)")
        }
    }
}
