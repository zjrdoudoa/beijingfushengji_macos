import Foundation

public enum GameStatus: String, Codable, Equatable {
    case inProgress
    case won
    case lost
}

public struct GameEnding: Codable, Equatable {
    public var status: GameStatus
    public var reasonKey: String
    public var finalScore: Int

    public init(status: GameStatus, reasonKey: String, finalScore: Int) {
        self.status = status
        self.reasonKey = reasonKey
        self.finalScore = finalScore
    }
}

public struct GameState: Codable, Equatable {
    public var version: Int
    public var day: Int
    public var maxDays: Int
    public var status: GameStatus
    public var player: Player
    public var locations: [Location]
    public var products: [Product]
    public var market: [MarketPrice]
    public var eventLog: [EventLogEntry]
    public var transactions: [Transaction]
    public var activeNewsKey: String?
    public var ending: GameEnding?

    public init(
        version: Int,
        day: Int,
        maxDays: Int,
        status: GameStatus,
        player: Player,
        locations: [Location],
        products: [Product],
        market: [MarketPrice],
        eventLog: [EventLogEntry] = [],
        transactions: [Transaction] = [],
        activeNewsKey: String? = nil,
        ending: GameEnding? = nil
    ) {
        self.version = version
        self.day = day
        self.maxDays = maxDays
        self.status = status
        self.player = player
        self.locations = locations
        self.products = products
        self.market = market
        self.eventLog = eventLog
        self.transactions = transactions
        self.activeNewsKey = activeNewsKey
        self.ending = ending
    }
}
