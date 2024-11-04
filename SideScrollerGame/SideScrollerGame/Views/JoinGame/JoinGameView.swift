//
//  JoinGameView.swift
//  SideScrollerGame
//
//  Created by Jairo Júnior on 25/09/24.
//

import SwiftUI
import GameKit

struct JoinGameView: View {
    @Bindable var managerMP: MultiplayerManager = .shared
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                // Title Image
                HStack {
                    Image("titleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5)
                    Spacer()
                }.padding(.top, 50)
                Spacer()
                Spacer()
                
                HStack {
                    Image("playButtonImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.2)
                        .onTapGesture {
                            if managerMP.automatch {
                                // Turn automatch off.
                                GKMatchmaker.shared().cancel()
                                managerMP.automatch = false
                            }
                            managerMP.choosePlayer()
                        }
                    Spacer()
                }
                .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.horizontal, 40)

        }
    }
}
#Preview {
    JoinGameView(managerMP: MultiplayerManager())
}
