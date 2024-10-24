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
                    .background(self.mpManager.gameStartInfo.other.eraSelection == perspective ? Color.red : self.playerStartInfo.eraSelection == perspective ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        
            if (mpManager.gameStartInfo.local.eraSelection != mpManager.gameStartInfo.other.eraSelection) && (mpManager.gameStartInfo.local.eraSelection != nil && mpManager.gameStartInfo.other.eraSelection != nil) {
                
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
