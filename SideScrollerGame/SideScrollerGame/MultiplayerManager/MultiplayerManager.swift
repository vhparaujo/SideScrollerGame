//
//  MultiplayerManager.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit
import SwiftUI

@Observable
class MultiplayerManager: NSObject {
    var selfPlayerInfo: PlayerInfo = .init(position: .zero)
    var otherPlayerInfo: PlayerInfo = .init(position: .zero)
    
    
    var friendList: [Friend] = []
    
    //game interface state
    var matchAvailable = false
    var playingGame = false
    var myMatch: GKMatch? = nil
    var automatch = false
    
    //match information
    var opponent: GKPlayer? = nil
    
    /// The name of the match.
    var matchName: String {
        "\(opponentName) Match"
    }
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.displayName ?? "Invitation Pending"
    }
    
    /// The root view controller of the window.
    override init(){
        super.init()
        authenticatePlayer()
    }
    
    var rootViewController: NSViewController? {
        guard let window = NSApplication.shared.windows.first else {
            return nil
        }
        return window.contentViewController
    }
    
    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        // Set the authentication handler that GameKit invokes.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // If the view controller is non-nil, present it to the player so they can
                // perform some necessary action to complete authentication.
                self.rootViewController?.presentAsModalWindow(viewController)
                return
            }
            if let error {
                // If you can’t authenticate the player, disable Game Center features in your game.
                print("Error: \(error.localizedDescription).")
                return
            }

            // Register for real-time invitations from other players.
            GKLocalPlayer.local.register(self)
            
            // Add an access point to the interface.
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            
            // Enable the Start Game button.
            self.matchAvailable = true
        }
    }
    
    /// Presents the matchmaker interface where the local player selects and sends an invitation to another player.
    /// - Tag:choosePlayer
    func choosePlayer() {
        // Create a match request.
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        // If you use matchmaking rules, set the GKMatchRequest.queueName property here. If the rules use
        // game-specific properties, set the local player's GKMatchRequest.properties too.
        
        // Present the interface where the player selects opponents and starts the game.
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            rootViewController?.presentAsSheet(viewController)
        }
    }
    
    // Starting and stopping the game.
    
    /// Starts a match.
    /// - Parameter match: The object that represents the real-time match.
    /// - Tag:startMyMatchWith
    func startMatch(match: GKMatch) {
        GKAccessPoint.shared.isActive = false
        playingGame = true
        myMatch = match
        myMatch?.delegate = self
    }
    
    /// Stops the current match, cleans up resources, and returns to the main interface.
    /// - Tag:stopGame
    func endMatch() {
        // If there's a match ongoing, end it
        if let match = myMatch {
            match.disconnect()
            myMatch = nil
        }
        
        // Reset game state
        playingGame = false
        matchAvailable = true
        selfPlayerInfo = PlayerInfo(position: .zero)
        otherPlayerInfo = PlayerInfo(position: .zero)
        
        // Clear opponent and scores
        opponent = nil
        
        // Reactivate the access point so the player can start another game
        GKAccessPoint.shared.isActive = true
        
        // Optionally, return to the main interface or reset views
        // This depends on how you structure your views/UI
        
        print("Game has been stopped and reset.")
    }

    
    /// Takes the player's turn.
    /// - Tag:takeAction
    func takeAction() {
        //remember to update the value of the self player before send to the other player
        
        // Otherwise, send the game data to the other player.
        do {
            let data = encode(content: selfPlayerInfo)
            try myMatch?.sendData(toAllPlayers: data!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
}
