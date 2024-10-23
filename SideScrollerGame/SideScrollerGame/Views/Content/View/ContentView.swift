//
//  ContentView.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var mpManager = MultiplayerManager.shared
    
    var body: some View {
        if mpManager.gameStartInfo.localPlayerStartInfo.isStartPressed == .yes && mpManager.gameStartInfo.otherPlayerStartInfo.isStartPressed == .yes {
            if let era = mpManager.gameStartInfo.localPlayerStartInfo.eraSelection {
        GameView()
            }
            
        }else if mpManager.choosingEra {
            ChoosePerspectiveView(playerStartInfo: .init( isStartPressed: .no))
        }else{
            JoinGameView()
        }
//        if !mpManager.gameFinished {
//            GameView()
//        } else {
//            EndGameView()
//        }
//        GameView(currentSceneType: .first(.present), mpManager: managerMP)

    }
}

#Preview {
    ContentView()
}

