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
        
        VStack {
            
            Image("ChoosePerspective")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top)
                .padding()
            
            HStack {
                ForEach(PlayerEra.allCases, id: \.self) { perspective in
                    
                    if perspective == PlayerEra.future {
                        ZStack {
                            Image("FutureChoose")
                                .resizable()
                                .scaleEffect(0.5)
                                .aspectRatio(contentMode: .fit)
                            VStack {
                                Image("player-future-idle-left-1")
                                    .resizable()
                                    .scaleEffect(0.35)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .offset(y: -50)
                        }
                        .onTapGesture {
                            self.playerStartInfo.eraSelection = perspective
                            mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                        }
                    } else {
                        ZStack {
                            Image("PresentChoose")
                                .resizable()
                                .scaleEffect(0.5)

                                .aspectRatio(contentMode: .fit)
                            VStack {
                                Image("player-present-idle-right-1")
                                    .resizable()
                                    .scaleEffect(0.32)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .offset(y: -38)
                        }
                        .onTapGesture {
                            self.playerStartInfo.eraSelection = perspective
                            mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                        }
                    }
                }
            }
            
            if (mpManager.gameStartInfo.local.eraSelection != mpManager.gameStartInfo.other.eraSelection) && (mpManager.gameStartInfo.local.eraSelection != nil && mpManager.gameStartInfo.other.eraSelection != nil) {
                
                Button {
                    if mpManager.gameStartInfo.local.isStartPressed == .yes {
                        playerStartInfo.isStartPressed = .no
                        mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                    } else {
                        playerStartInfo.isStartPressed = .yes
                        mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                    }
                } label: {
                    Text(mpManager.gameStartInfo.local.isStartPressed == .yes ? "Cancel" : "Ready")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ChoosePerspectiveView(mpManager: .init(), playerStartInfo: .init(isStartPressed: .no))
}
