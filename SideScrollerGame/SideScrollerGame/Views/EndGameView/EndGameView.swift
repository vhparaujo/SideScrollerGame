//
//  SwiftUIView.swift
//  SideScrollerGame
//
//  Created by Victor Hugo Pacheco Araujo on 22/10/24.
//

import SwiftUI

struct EndGameView: View {
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
                
            }
   
        }
    }
}

#Preview {
    EndGameView()
}
