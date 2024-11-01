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
//        if mpManager.gameStartInfo.local.isStartPressed == .yes && mpManager.gameStartInfo.other.isStartPressed == .yes &&
//            !mpManager.gameFinished{
        GameView()
            
//            
//        }else if mpManager.gameFinished &&
//                    !mpManager.choosingEra &&
//                    mpManager.gameStartInfo.local.isStartPressed == .yes &&
//                    mpManager.gameStartInfo.other.isStartPressed == .yes {
//            EndGameView()
//            
//        }else if mpManager.choosingEra {
//            ChoosePerspectiveView(playerStartInfo: .init( isStartPressed: .no))
//        }else{
//            JoinGameView()
//        }
    
    }
}

#Preview {
    ContentView()
}

