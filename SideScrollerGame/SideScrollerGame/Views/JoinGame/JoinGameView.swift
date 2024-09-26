//
//  JoinGameView.swift
//  SideScrollerGame
//
//  Created by Jairo Júnior on 25/09/24.
//

import SwiftUI
import GameKit

struct JoinGameView: View {
    @Bindable var managerMP: MultiplayerManager
    var body: some View {
        Button("Start Game"){
            if managerMP.automatch {
                // Turn automatch off.
                GKMatchmaker.shared().cancel()
                managerMP.automatch = false
            }
            managerMP.choosePlayer()
        }.buttonStyle(.borderedProminent)
    }
}

#Preview {
    JoinGameView(managerMP: MultiplayerManager())
}
