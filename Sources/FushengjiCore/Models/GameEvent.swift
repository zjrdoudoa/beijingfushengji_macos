import Foundation

public enum GameEventType: String, Codable, Equatable, CaseIterable {
    case price
    case health
    case loss
    case opportunity
}

public struct GameEventEffect: Codable, Equatable, Hashable {
    public var cashDelta: Int?
    public var debtDelta: Int?
    public var healthDelta: Int?
    public var cashMultiplier: Double?
    public var inventoryLossPercent: Double?
    public var targetProductID: String?
    public var priceMultiplier: Double?
    public var bonusProductID: String?
    public var bonusQuantity: Int?

    public init(
        cashDelta: Int? = nil,
        debtDelta: Int? = nil,
        healthDelta: Int? = nil,
        cashMultiplier: Double? = nil,
        inventoryLossPercent: Double? = nil,
        targetProductID: String? = nil,
        priceMultiplier: Double? = nil,
        bonusProductID: String? = nil,
        bonusQuantity: Int? = nil
    ) {
        self.cashDelta = cashDelta
        self.debtDelta = debtDelta
        self.healthDelta = healthDelta
        self.cashMultiplier = cashMultiplier
        self.inventoryLossPercent = inventoryLossPercent
        self.targetProductID = targetProductID
        self.priceMultiplier = priceMultiplier
        self.bonusProductID = bonusProductID
        self.bonusQuantity = bonusQuantity
    }
}

public struct GameEvent: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public var type: GameEventType
    public var titleKey: String
    public var bodyKey: String
    public var probability: Double
    public var locationIDs: [String]?
    public var productIDs: [String]?
    public var effect: GameEventEffect

    public init(
        id: String,
        type: GameEventType,
        titleKey: String,
        bodyKey: String,
        probability: Double,
        locationIDs: [String]? = nil,
        productIDs: [String]? = nil,
        effect: GameEventEffect
    ) {
        self.id = id
        self.type = type
        self.titleKey = titleKey
        self.bodyKey = bodyKey
        self.probability = probability
        self.locationIDs = locationIDs
        self.productIDs = productIDs
        self.effect = effect
    }
}

public struct EventLogEntry: Codable, Equatable, Hashable, Identifiable {
    public var id: UUID
    public var day: Int
    public var eventID: String
    public var type: GameEventType
    public var titleKey: String
    public var bodyKey: String

    public init(
        id: UUID = UUID(),
        day: Int,
        eventID: String,
        type: GameEventType,
        titleKey: String,
        bodyKey: String
    ) {
        self.id = id
        self.day = day
        self.eventID = eventID
        self.type = type
        self.titleKey = titleKey
        self.bodyKey = bodyKey
    }
}
