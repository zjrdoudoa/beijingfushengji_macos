import Foundation

public struct RoleStatusConfig: Codable, Equatable, Identifiable {
    public let id: String
    public var nameKey: String
    public var cash: Int
    public var debt: Int
    public var health: Int
    public var maxHealth: Int
    public var capacity: Int
    public var startLocationID: String

    public init(
        id: String,
        nameKey: String,
        cash: Int,
        debt: Int,
        health: Int,
        maxHealth: Int,
        capacity: Int,
        startLocationID: String
    ) {
        self.id = id
        self.nameKey = nameKey
        self.cash = cash
        self.debt = debt
        self.health = health
        self.maxHealth = maxHealth
        self.capacity = capacity
        self.startLocationID = startLocationID
    }
}

public struct EndingConditions: Codable, Equatable {
    public var debtFailureLimit: Int
    public var victoryNetWorth: Int
    public var victoryReasonKey: String
    public var debtFailureReasonKey: String
    public var healthFailureReasonKey: String
    public var brokeReasonKey: String

    public init(
        debtFailureLimit: Int,
        victoryNetWorth: Int,
        victoryReasonKey: String,
        debtFailureReasonKey: String,
        healthFailureReasonKey: String,
        brokeReasonKey: String
    ) {
        self.debtFailureLimit = debtFailureLimit
        self.victoryNetWorth = victoryNetWorth
        self.victoryReasonKey = victoryReasonKey
        self.debtFailureReasonKey = debtFailureReasonKey
        self.healthFailureReasonKey = healthFailureReasonKey
        self.brokeReasonKey = brokeReasonKey
    }
}

public struct GameRules: Codable, Equatable {
    public var defaultRoleID: String
    public var maxDays: Int
    public var debtInterestRate: Double
    public var travelHealthCost: Int
    public var maxBorrowAmount: Int
    public var endingConditions: EndingConditions

    public init(
        defaultRoleID: String,
        maxDays: Int,
        debtInterestRate: Double,
        travelHealthCost: Int,
        maxBorrowAmount: Int,
        endingConditions: EndingConditions
    ) {
        self.defaultRoleID = defaultRoleID
        self.maxDays = maxDays
        self.debtInterestRate = debtInterestRate
        self.travelHealthCost = travelHealthCost
        self.maxBorrowAmount = maxBorrowAmount
        self.endingConditions = endingConditions
    }

    public func debtAfterDailyInterest(_ debt: Int) -> Int {
        let interest = Double(debt) * debtInterestRate
        return debt + Int(interest.rounded(.toNearestOrAwayFromZero))
    }
}

public struct NewsItem: Codable, Equatable, Identifiable {
    public let id: String
    public var titleKey: String
    public var bodyKey: String

    public init(id: String, titleKey: String, bodyKey: String) {
        self.id = id
        self.titleKey = titleKey
        self.bodyKey = bodyKey
    }
}

public struct GameConfiguration: Codable, Equatable {
    public var version: Int
    public var rules: GameRules
    public var roles: [RoleStatusConfig]
    public var locations: [Location]
    public var products: [Product]
    public var events: [GameEvent]
    public var news: [NewsItem]

    public init(
        version: Int,
        rules: GameRules,
        roles: [RoleStatusConfig],
        locations: [Location],
        products: [Product],
        events: [GameEvent],
        news: [NewsItem]
    ) {
        self.version = version
        self.rules = rules
        self.roles = roles
        self.locations = locations
        self.products = products
        self.events = events
        self.news = news
    }
}
