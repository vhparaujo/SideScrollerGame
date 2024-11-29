//
//  SwiftUIView.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 22/10/24.
//

import SwiftUI

struct EndGameView: View {
    @Bindable var mpManager = MultiplayerManager.shared

    var body: some View {
        GeometryReader { geometry in
            VStack {
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
                    Image("buttonBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.2)
                        .onTapGesture {
                            mpManager.gameFinished = false
                            mpManager.endMatch()
                        }
                        .overlay {
                            Text("Back To Menu")
                                .font(.largeTitle)
                        }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(
                Image("startSceneBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .blur(radius: 3)
            )
            .padding(.horizontal, 40)
            
        }
    }
}

#Preview {
    EndGameView()
}
