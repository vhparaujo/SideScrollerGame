//
//  ContentView.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @Bindable var managerMP = MultiplayerManager()
    var body: some View {
        if managerMP.playingGame {
            GameView(mpManager: managerMP)
        }else{
            JoinGameView(managerMP: managerMP)
        }
    }
}

#Preview {
    ContentView()
}
