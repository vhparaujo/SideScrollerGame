import Foundation
import GameKit
import Combine

@Observable
class MultiplayerManager: NSObject {
    static var shared = MultiplayerManager()
    
    var localPlayer: PlayerInfo?
    var otherPlayerInfo: CurrentValueSubject<PlayerInfo?, Never> = CurrentValueSubject(nil)
    
    var gameStartInfo: GameStartInfo = .init(local: .init(isStartPressed: .no), other: .init(isStartPressed: .no))
    
    // Game interface state
    var matchAvailable = false
    var playingGame = false
    var choosingEra = false
    var myMatch: GKMatch? = nil
    var automatch = false
    var gameFinished = false
    var backToMenu = false
    // Match information
    var opponent: GKPlayer? = nil {
        didSet {
            print(opponent)
        }
    }
    
    //boxes
    var scenesGeneralBoxes: [UUID: BoxTeletransport] = [:]

    //spawnPoint
    var spawnpoint: CGPoint = .zero
    
    /// The name of the match.
    var matchName: String {
        "\(opponentName) Match"
    }
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String?
    
    /// The root view controller of the window.
    override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    var rootViewController: NSViewController? {
        guard let window = NSApplication.shared.windows.first else {
            return nil
        }
        return window.contentViewController
    }
    
    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                self.rootViewController?.presentAsModalWindow(viewController)
                return
            }
            if let error = error {
                print("Error authenticating player: \(error)")
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
        choosingEra = true
        myMatch = match
        myMatch?.delegate = self
    }
    
    /// Stops the current match and cleans up resources.
    func endMatch() {
        gameStartInfo.local.eraSelection = nil
        gameStartInfo.local.isStartPressed = .no
        myMatch?.disconnect()
        myMatch = nil
        gameFinished = true
        playingGame = false
        choosingEra = false
        matchAvailable = true
        localPlayer = nil
        otherPlayerInfo.value = nil
        gameStartInfo.local.eraSelection = nil
        gameStartInfo.other.eraSelection = nil
        opponent = nil
        GKAccessPoint.shared.isActive = true
    }

    /// Sends player info to other players.
    func sendInfoToOtherPlayers(playerInfo: PlayerInfo) {
        localPlayer = playerInfo
        do {
            let data = encode(content: playerInfo)
            try myMatch?.sendData(toAllPlayers: data!, with: .unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func sendInfoToOtherPlayers(content: PlayerStartInfo){
        gameStartInfo.local = content
        
        do {
            let data = encode(content: content)
            try myMatch?.sendData(toAllPlayers: data!, with: .unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func sendInfoToOtherPlayers(content: BoxTeletransport){
        self.scenesGeneralBoxes[content.id] = content
        
        do {
            let data = encode(content: content)
            try myMatch?.sendData(toAllPlayers: data!, with: .unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    func sendInfoToOtherPlayers(content: CGPoint){
        self.spawnpoint = content
        
        do {
            let data = encode(content: content)
            try myMatch?.sendData(toAllPlayers: data!, with: .unreliable)
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }

}
