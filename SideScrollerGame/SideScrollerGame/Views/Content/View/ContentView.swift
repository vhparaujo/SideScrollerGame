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
        if managerMP.gameStartInfo?.localPlayerStartInfo.isStartPressed == .yes && managerMP.gameStartInfo?.localPlayerStartInfo.isStartPressed == .yes {
            
            if let era = managerMP.gameStartInfo?.localPlayerStartInfo.eraSelection {
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

