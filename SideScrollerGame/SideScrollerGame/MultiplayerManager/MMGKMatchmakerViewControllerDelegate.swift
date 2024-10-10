//
//  MMGKMatchmakerViewControllerDelegate.swift
//  CubeEatForIos
//
//  Created by Jairo Júnior on 24/09/24.
//

import Foundation
import GameKit
import SwiftUI

extension MultiplayerManager: GKMatchmakerViewControllerDelegate {
    /// Dismisses the matchmaker interface and starts the game when a player accepts an invitation.
    func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                  didFind match: GKMatch) {
        // Dismiss the view controller.
        viewController.dismiss(true)

        // Start the game with the player.
        if !playingGame && match.expectedPlayerCount == 0 {
            startMatch(match: match)
        }
    }
    
    /// Dismisses the matchmaker interface when either player cancels matchmaking.
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        endMatch()
        viewController.dismiss(true)
    }
    
    /// Reports an error during the matchmaking process.
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        endMatch()
        viewController.dismiss(true)
    }
}
