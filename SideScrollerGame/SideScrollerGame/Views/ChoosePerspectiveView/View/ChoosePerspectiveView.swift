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
                        VStack {
                            if self.playerStartInfo.eraSelection == .future &&  self.mpManager.gameStartInfo.other.eraSelection != .future  {
                                Text(mpManager.myName)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.backgroundName)
                                    }
                            } else if self.mpManager.gameStartInfo.other.eraSelection == .future &&  self.playerStartInfo.eraSelection != .future {
                                Text(mpManager.opponentName ?? "Other Player")
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.backgroundName)
                                    }
                            } else if self.mpManager.gameStartInfo.other.eraSelection == .future && self.playerStartInfo.eraSelection == .future {
                                HStack {
                                    Text(mpManager.myName)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle(Color.backgroundName)
                                        }
                                    Text(mpManager.opponentName ?? "Other Player")
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle(Color.backgroundName)
                                        }
                                }
                            }
                            VStack(spacing: 0) {
                                Image("FutureChoose")
                                    .resizable()
                                    .scaleEffect(0.5)
                                    .aspectRatio(contentMode: .fit)
                                
                                    .overlay {
                                        VStack {
                                            Text("Future")
                                                .font(.largeTitle)
                                                .padding(.top, 280)
                                        }
                                    }
                                
//                                Image("buttonBackground")
//                                    .resizable()
//                                    .scaleEffect(0.25)
//                                    .aspectRatio(contentMode: .fit)
//                                    .overlay {
//                                        Text("Future")
//                                            .font(.largeTitle)
//                                    }
                            }
                            .onTapGesture {
                                self.playerStartInfo.eraSelection = perspective
                                mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                            }
                        }
                    } else {
                        VStack {
                            if self.playerStartInfo.eraSelection == .present &&  self.mpManager.gameStartInfo.other.eraSelection != .present  {
                                Text(mpManager.myName)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.backgroundName)
                                    }
                            } else if self.mpManager.gameStartInfo.other.eraSelection == .present &&  self.playerStartInfo.eraSelection != .present {
                                Text(mpManager.opponentName ?? "Other Player")
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.backgroundName)
                                    }
                            } else if self.mpManager.gameStartInfo.other.eraSelection == .present && self.playerStartInfo.eraSelection == .present {
                                HStack {
                                    Text(mpManager.myName)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle(Color.backgroundName)
                                        }
                                    Text(mpManager.opponentName ?? "Other Player")
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundStyle(Color.backgroundName)
                                        }
                                }
                            }
                            VStack(spacing: 0) {
                                Image("PresentChoose")
                                    .resizable()
                                    .scaleEffect(0.5)
                                    .aspectRatio(contentMode: .fit)
                                
                                Image("buttonBackground")
                                    .resizable()
                                    .scaleEffect(0.25)
                                    .aspectRatio(contentMode: .fit)
                                    .overlay {
                                        Text("Present")
                                            .font(.largeTitle)
                                    }
                                
                            }
                            .onTapGesture {
                                self.playerStartInfo.eraSelection = perspective
                                mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                            }
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
