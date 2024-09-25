//
//  MMMatchData.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit
import SwiftUI

extension MultiplayerManager {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the local player's score for sending to other players.
    ///
    /// - Returns: A representation of game data that contains only the score.
    ///
    
    func encode(position: CGPoint) -> Data?{
        let playerInfo = PlayerInfo(position: position)
        return encode(content: playerInfo)
    }
    
    /// Creates a data representation of game data for sending to other players.
    ///
    /// - Returns: A representation of game data.
    func encode<T:Codable>(content: T) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(content)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
    
    /// Decodes a data representation of match data from another player.
    ///
    /// - Parameter matchData: A data representation of the game data.
    /// - Returns: A game data object.
    func decode(matchData: Data) -> PlayerInfo? {
        // Convert the data object to a game data object.
        return try? PropertyListDecoder().decode(PlayerInfo.self, from: matchData)
    }
}
