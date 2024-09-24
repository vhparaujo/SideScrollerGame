//
//  SideScrollerGameApp.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI
import SwiftData

@main
struct SideScrollerGameApp: App {
    
    var controllers = GameController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(controllers)
        }
    }
}
