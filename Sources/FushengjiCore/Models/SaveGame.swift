import Foundation

public struct SaveGame: Codable, Equatable, Identifiable {
    public var id: UUID
    public var slot: String
    public var createdAt: Date
    public var updatedAt: Date
    public var appVersion: String
    public var seedState: UInt64
    public var state: GameState

    public init(
        id: UUID = UUID(),
        slot: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        appVersion: String,
        seedState: UInt64,
        state: GameState
    ) {
        self.id = id
        self.slot = slot
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.appVersion = appVersion
        self.seedState = seedState
        self.state = state
    }
}
