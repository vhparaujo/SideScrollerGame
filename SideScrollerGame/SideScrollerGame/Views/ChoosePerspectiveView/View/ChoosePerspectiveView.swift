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
    @State private var countdown: Int = 5
    @State private var isCountingDown = false
    
    // Replace `yourVariable` with the actual variable you want to monitor for changes
    @State private var shouldStopTimer: Bool = false
    
    var body: some View {
        VStack {
            Image("ChoosePerspective")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top)
                .padding()
            
            HStack {
                ForEach(PlayerEra.allCases, id: \.self) { perspective in
                    VStack {
                        if perspective == PlayerEra.future {
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
                        } else {
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
                        }
                        
                        if perspective == PlayerEra.future {
                            perspectiveView(for: perspective, image: "FutureChoose")
                        } else {
                            perspectiveView(for: perspective, image: "PresentChoose")
                        }
                    }
                }
            }
            
            if isCountingDown {
                Text("Starting in \(countdown) seconds...")
                    .font(.headline)
                    .padding()
            }
        }
        .padding()
        .onChange(of: shouldStopTimer) { _, newValue in
            if newValue {
                stopCountdown()
                shouldStopTimer = false
            }
        }
        .onChange(of: playerStartInfo.eraSelection) { _, newValue in
            if newValue == mpManager.gameStartInfo.other.eraSelection || mpManager.gameStartInfo.other.eraSelection == nil {
                shouldStopTimer = true
            }else if newValue != mpManager.gameStartInfo.other.eraSelection && mpManager.gameStartInfo.other.eraSelection == nil{
                startCountdown()
            }
        }
        .onChange(of: mpManager.gameStartInfo.other.eraSelection) { _, newValue in
            if newValue == playerStartInfo.eraSelection || playerStartInfo.eraSelection == nil {
                shouldStopTimer = true
            } else if newValue != playerStartInfo.eraSelection && playerStartInfo.eraSelection == nil{
                startCountdown()
            }
        }
        .background {
            Image("startSceneBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 3)
        }
    }
    
    private func perspectiveView(for perspective: PlayerEra, image: String) -> some View {
        VStack(spacing: 0) {
            Image(image)
                .resizable()
                .scaleEffect(0.5)
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    self.playerStartInfo.eraSelection = perspective
                    mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
                }
        }
    }
    
    private func startCountdown() {
        countdown = 5
        isCountingDown = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                isCountingDown = false
                // Take any additional action here when the countdown reaches zero
                
                playerStartInfo.isStartPressed = .yes
                mpManager.sendInfoToOtherPlayers(content: playerStartInfo)
            }
            
            if shouldStopTimer {
                timer.invalidate()
                isCountingDown = false
            }
        }
    }
    
    private func stopCountdown() {
        isCountingDown = false
    }
}

#Preview {
    ChoosePerspectiveView(mpManager: .init(), playerStartInfo: .init(isStartPressed: .no))
}
