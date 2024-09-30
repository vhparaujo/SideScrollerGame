import Foundation
import GameKit
import Combine

@Observable
class MultiplayerManager: NSObject {
    var selfPlayerInfo: PlayerInfo? 
    
    var otherPlayerInfo: CurrentValueSubject<PlayerInfo?, Never> = CurrentValueSubject(nil)
    
    // Game interface state
    var matchAvailable = false
    var playingGame = false
    var myMatch: GKMatch? = nil
    var automatch = false
    
    // Match information
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
    override init() {
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
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                self.rootViewController?.presentAsModalWindow(viewController)
                return
            }
            if let error = error {
                print("Error: \(error.localizedDescription).")
                return
            }
            GKLocalPlayer.local.register(self)
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            self.matchAvailable = true
        }
    }
    
    /// Presents the matchmaker interface where the local player selects and sends an invitation to another player.
    func choosePlayer() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            rootViewController?.presentAsSheet(viewController)
        }
    }
    
    /// Starts a match.
    func startMatch(match: GKMatch) {
        GKAccessPoint.shared.isActive = false
        playingGame = true
        myMatch = match
        myMatch?.delegate = self
    }
    
    /// Stops the current match and cleans up resources.
    func endMatch() {
        if let match = myMatch {
            match.disconnect()
            myMatch = nil
        }
        
        playingGame = false
        matchAvailable = true
        selfPlayerInfo = nil
        otherPlayerInfo.value = nil
        opponent = nil
        GKAccessPoint.shared.isActive = true
        
        print("Game has been stopped and reset.")
    }

    /// Sends player info to other players.
    func sendInfoToOtherPlayers(playerInfo: PlayerInfo) {
        selfPlayerInfo = playerInfo 
        do {
            let data = encode(content: playerInfo)
            try myMatch?.sendData(toAllPlayers: data!, with: .unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
}
