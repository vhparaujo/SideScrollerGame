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
        VStack {
            
            Text("End Game")
                .font(.title)
            Text("Congratulations!!")
                .font(.title2)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                Text("Back to menu")
                    .font(.title)
                    .bold()
            }
            .padding()
            .frame(maxWidth: 300, maxHeight: 100)
            .onTapGesture {
                mpManager.gameFinished = false
                mpManager.endMatch()
            }
            .onAppear {
                mpManager.endMatch()
            }
        }
    }
}

#Preview {
    EndGameView()
}
