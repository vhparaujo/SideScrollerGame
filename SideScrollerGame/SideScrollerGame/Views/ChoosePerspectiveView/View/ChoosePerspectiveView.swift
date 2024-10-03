//
//  ChoosePerspectiveView.swift
//  SideScrollerGame
//
//  Created by Jairo Júnior on 03/10/24.
//

import SwiftUI



struct ChoosePerspectiveView: View {
    @Bindable var mpManager: MultiplayerManager
    @State var perspective: PlayerEra?
    
    var body: some View {
        HStack {
            ForEach(PlayerEra.allCases, id: \.self) { perspective in
                Button("\(perspective)") {
                    self.perspective = perspective
                    mpManager.sendInfoToOtherPlayers(eraUpdate: perspective)
                }
                .padding()
                .background(self.perspective == perspective ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if mpManager.gameStartInfo.playerEraSelection != mpManager.gameStartInfo.otherPlayerEraSelection {
                
                Button("Start Game") {
                    
                    mpManager.sendInfoToOtherPlayers(content: .yes)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ChoosePerspectiveView(mpManager: .init())
}
