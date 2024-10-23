//
//  ChoosePerspectiveView.swift
//  SideScrollerGame
//
//  Created by Jairo Júnior on 03/10/24.
//

import SwiftUI



struct ChoosePerspectiveView: View {
    @Bindable var mpManager: MultiplayerManager = .shared
    @State var playerStartInfo: PlayerStartInfo
    
    
    var body: some View {
        VStack{
            HStack {
                ForEach(PlayerEra.allCases, id: \.self) { perspective in
                    Button("\(perspective)") {
                        self.playerStartInfo.eraSelection = perspective
                        mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                    }
                    .padding()
                    .background(self.mpManager.gameStartInfo.otherPlayerStartInfo.eraSelection == perspective ? Color.red : self.playerStartInfo.eraSelection == perspective ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        
            if (mpManager.gameStartInfo.localPlayerStartInfo.eraSelection != mpManager.gameStartInfo.otherPlayerStartInfo.eraSelection) && (mpManager.gameStartInfo.localPlayerStartInfo.eraSelection != nil && mpManager.gameStartInfo.otherPlayerStartInfo.eraSelection != nil) {
                
                Button {
                        playerStartInfo.isStartPressed = .yes
                    
                    mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                    
                } label: {
                    Text("Ready")
                  
                }
            }
        }
        .padding()
    }
}


#Preview {
    ChoosePerspectiveView(mpManager: .init(), playerStartInfo: .init(isStartPressed: .no))
}
