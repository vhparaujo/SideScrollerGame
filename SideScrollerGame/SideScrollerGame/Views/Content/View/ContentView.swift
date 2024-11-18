//
//  ContentView.swift
//  SideScrollerGame
//
//  Created by Eduardo on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var mpManager = MultiplayerManager.shared
    @State var gotoGame: Bool = false
    
    var body: some View {
        if !mpManager.gameFinished && gotoGame {
            let _ = print("Entrou no GameView")
            GameView(viewModel: .init(currentSceneType: .first(mpManager.gameStartInfo.local.eraSelection!)))
            
        } else if mpManager.gameFinished {
            EndGameView()
                .onAppear {
                    gotoGame = false
                }
            
        } else if mpManager.choosingEra {
            ChoosePerspectiveView(gotogame: $gotoGame, playerStartInfo: .init( isStartPressed: .no))
        } else {
            JoinGameView()
        }
//        GameView()

    }
}

#Preview {
    ContentView()
}
