//
//  MMGKMatchDelegate.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit
import SwiftUI

extension MultiplayerManager: GKMatchDelegate {
    /// Handles a connected, disconnected, or unknown player state.
    /// - Tag:didChange
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            
            // For automatch, set the opponent and load their avatar.
            if match.expectedPlayerCount == 0 {
                opponent = match.players[0]
                
            }
        case .disconnected:
            
            self.endMatch()
        default:
            self.endMatch()
        }
    }
    
    /// Handles an error during the matchmaking process.
    func match(_ match: GKMatch, didFailWithError error: Error?) {
    }

    /// Reinvites a player when they disconnect from the match.
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return false
    }
    
    /// Handles receiving a message from another player.
    /// - Tag:didReceiveData
    /// Handles receiving a message from another player.
    /// - Tag: didReceiveData
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Tenta decodificar como PlayerInfo
        if let dataReceived: PlayerInfo = decode(matchData: data) {
            self.otherPlayerInfo.value = dataReceived
            
        }else if let dataReceived: PlayerStartInfo = decode(matchData: data) {
            self.gameStartInfo.otherPlayerStartInfo = dataReceived

        }else if let dataReceived: BoxTeletransport = decode(matchData: data) {
            
            if let index = self.firstSceneBoxes.firstIndex(where: { $0.id == dataReceived.id }) {
                self.firstSceneBoxes[index].position = dataReceived.position
            }else{
                self.firstSceneBoxes.append(dataReceived)
            }
        }
        
    }
}


