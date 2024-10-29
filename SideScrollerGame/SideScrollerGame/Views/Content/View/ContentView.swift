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
//        if mpManager.gameStartInfo.local.isStartPressed == .yes && mpManager.gameStartInfo.other.isStartPressed == .yes {
//        GameView()
//            
//            
//        }else if mpManager.choosingEra {
//            ChoosePerspectiveView(playerStartInfo: .init( isStartPressed: .no))
//        }else{
//            JoinGameView()
//        }

//        GameView(currentSceneType: .first(.future))
        
        if !mpManager.gameFinished {
            GameView()
         } else {
             EndGameView()
         }
    
    }
}

#Preview {
    ContentView()
}

