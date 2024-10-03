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
        if managerMP.gameStartInfo.isStartPressedByPlayer == .yes && managerMP.gameStartInfo.isStartPressedByOtherPlayer == .yes {
            
            if let era = managerMP.gameStartInfo.playerEraSelection {
                GameView(currentSceneType: .first(era), mpManager: managerMP)
            }
        }else if managerMP.choosingEra {
            ChoosePerspectiveView(mpManager: managerMP)
        }else{
            JoinGameView(managerMP: managerMP)
        }
        
    }
}

#Preview {
    ContentView()
}

