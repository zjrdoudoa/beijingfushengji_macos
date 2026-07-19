import Foundation

public enum GameEngineError: Error, Equatable, LocalizedError {
    case configurationNotFound
    case invalidConfiguration(String)
    case gameAlreadyEnded
    case productNotFound(String)
    case locationNotFound(String)
    case priceNotFound(String)
    case invalidQuantity
    case insufficientCash
    case insufficientInventory
    case insufficientCapacity
    case alreadyAtLocation
    case debtLimitReached
    case eventNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .configurationNotFound:
            return "Game configuration was not found."
        case .invalidConfiguration(let reason):
            return "Invalid game configuration: \(reason)"
        case .gameAlreadyEnded:
            return "The game has already ended."
        case .productNotFound(let id):
            return "Product not found: \(id)"
        case .locationNotFound(let id):
            return "Location not found: \(id)"
        case .priceNotFound(let id):
            return "Market price not found: \(id)"
        case .invalidQuantity:
            return "Quantity must be greater than zero."
        case .insufficientCash:
            return "Not enough cash."
        case .insufficientInventory:
            return "Not enough inventory."
        case .insufficientCapacity:
            return "Not enough bag capacity."
        case .alreadyAtLocation:
            return "Already at this location."
        case .debtLimitReached:
            return "Borrowing would exceed the debt limit."
        case .eventNotFound(let id):
            return "Event not found: \(id)"
        }
    }
}

public final class GameEngine {
    public private(set) var state: GameState
    public var seedState: UInt64 { rng.state }

    private let configuration: GameConfiguration
    private let marketService: MarketService
    private let eventService: EventService
    private var rng: SeededRandomNumberGenerator

    public init(
        configuration: GameConfiguration,
        seed: UInt64 = 1,
        marketService: MarketService = MarketService(),
        eventService: EventService = EventService()
    ) throws {
        var generator = SeededRandomNumberGenerator(seed: seed)
        let initialState = try Self.makeInitialState(
            configuration: configuration,
            marketService: marketService,
            rng: &generator
        )

        self.configuration = configuration
        self.marketService = marketService
        self.eventService = eventService
        self.rng = generator
        self.state = initialState
    }

    public init(
        configuration: GameConfiguration,
        saveGame: SaveGame,
        marketService: MarketService = MarketService(),
        eventService: EventService = EventService()
    ) {
        self.configuration = configuration
        self.marketService = marketService
        self.eventService = eventService
        self.rng = SeededRandomNumberGenerator(restoringState: saveGame.seedState)
        self.state = saveGame.state
    }

    public func newGame(seed: UInt64 = 1) throws {
        var generator = SeededRandomNumberGenerator(seed: seed)
        state = try Self.makeInitialState(
            configuration: configuration,
            marketService: marketService,
            rng: &generator
        )
        rng = generator
    }

    @discardableResult
    public func buy(productID: String, quantity: Int) throws -> Transaction {
        try ensureGameIsActive()
        guard quantity > 0 else { throw GameEngineError.invalidQuantity }
        guard state.products.contains(where: { $0.id == productID }) else {
            throw GameEngineError.productNotFound(productID)
        }
        guard let price = marketService.price(for: productID, in: state.market) else {
            throw GameEngineError.priceNotFound(productID)
        }

        let total = price.price * quantity
        guard state.player.cash >= total else { throw GameEngineError.insufficientCash }
        guard state.player.availableCapacity >= quantity else { throw GameEngineError.insufficientCapacity }

        state.player.cash -= total
        state.player.addInventory(productID: productID, quantity: quantity, unitPrice: price.price)

        let transaction = Transaction(
            day: state.day,
            kind: .buy,
            productID: productID,
            quantity: quantity,
            unitPrice: price.price,
            total: -total,
            locationID: state.player.currentLocationID
        )
        state.transactions.append(transaction)
        return transaction
    }

    @discardableResult
    public func sell(productID: String, quantity: Int) throws -> Transaction {
        try ensureGameIsActive()
        guard quantity > 0 else { throw GameEngineError.invalidQuantity }
        guard state.player.quantity(of: productID) >= quantity else {
            throw GameEngineError.insufficientInventory
        }
        guard let price = marketService.price(for: productID, in: state.market) else {
            throw GameEngineError.priceNotFound(productID)
        }

        let total = price.price * quantity
        guard state.player.removeInventory(productID: productID, quantity: quantity) else {
            throw GameEngineError.insufficientInventory
        }

        state.player.cash += total
        let transaction = Transaction(
            day: state.day,
            kind: .sell,
            productID: productID,
            quantity: quantity,
            unitPrice: price.price,
            total: total,
            locationID: state.player.currentLocationID
        )
        state.transactions.append(transaction)
        return transaction
    }

    @discardableResult
    public func travel(to locationID: String) throws -> Transaction {
        try ensureGameIsActive()
        guard state.player.currentLocationID != locationID else { throw GameEngineError.alreadyAtLocation }
        guard let destination = state.locations.first(where: { $0.id == locationID }) else {
            throw GameEngineError.locationNotFound(locationID)
        }
        guard state.player.cash >= destination.travelCost else {
            throw GameEngineError.insufficientCash
        }

        state.player.cash -= destination.travelCost
        state.player.health = max(0, state.player.health - configuration.rules.travelHealthCost)
        state.player.currentLocationID = locationID

        let transaction = Transaction(
            day: state.day,
            kind: .travel,
            total: -destination.travelCost,
            locationID: locationID
        )
        state.transactions.append(transaction)

        try advanceDay(applyRandomEvent: true)
        return transaction
    }

    public func advanceDay(applyRandomEvent: Bool = true) throws {
        try ensureGameIsActive()

        state.day += 1
        state.player.debt = configuration.rules.debtAfterDailyInterest(state.player.debt)

        if evaluateImmediateEndConditions() {
            return
        }

        if state.day > state.maxDays {
            settleEndOfGame()
            return
        }

        try refreshMarket()

        if applyRandomEvent, let event = eventService.rollEvent(
            for: state,
            events: configuration.events,
            rng: &rng
        ) {
            try apply(event: event)
        }

        _ = evaluateImmediateEndConditions()
    }

    public func triggerEvent(id: String) throws {
        try ensureGameIsActive()
        guard let event = configuration.events.first(where: { $0.id == id }) else {
            throw GameEngineError.eventNotFound(id)
        }
        try apply(event: event)
        _ = evaluateImmediateEndConditions()
    }

    @discardableResult
    public func repayDebt(amount: Int) throws -> Transaction {
        try ensureGameIsActive()
        guard amount > 0 else { throw GameEngineError.invalidQuantity }

        let payment = min(amount, state.player.cash, state.player.debt)
        guard payment > 0 else { throw GameEngineError.insufficientCash }

        state.player.cash -= payment
        state.player.debt -= payment

        let transaction = Transaction(
            day: state.day,
            kind: .debtPayment,
            total: -payment,
            locationID: state.player.currentLocationID
        )
        state.transactions.append(transaction)
        return transaction
    }

    @discardableResult
    public func borrow(amount: Int) throws -> Transaction {
        try ensureGameIsActive()
        guard amount > 0 else { throw GameEngineError.invalidQuantity }
        guard state.player.debt + amount <= configuration.rules.maxBorrowAmount else {
            throw GameEngineError.debtLimitReached
        }

        state.player.cash += amount
        state.player.debt += amount

        let transaction = Transaction(
            day: state.day,
            kind: .debtBorrow,
            total: amount,
            locationID: state.player.currentLocationID
        )
        state.transactions.append(transaction)
        _ = evaluateImmediateEndConditions()
        return transaction
    }

    public func makeSaveGame(slot: String, appVersion: String = "0.1.0") -> SaveGame {
        SaveGame(
            slot: slot,
            appVersion: appVersion,
            seedState: seedState,
            state: state
        )
    }

    private static func makeInitialState(
        configuration: GameConfiguration,
        marketService: MarketService,
        rng: inout SeededRandomNumberGenerator
    ) throws -> GameState {
        guard let role = configuration.roles.first(where: { $0.id == configuration.rules.defaultRoleID }) else {
            throw GameEngineError.invalidConfiguration("Default role is missing.")
        }

        guard let startLocation = configuration.locations.first(where: { $0.id == role.startLocationID }) else {
            throw GameEngineError.invalidConfiguration("Start location is missing.")
        }

        guard !configuration.products.isEmpty else {
            throw GameEngineError.invalidConfiguration("At least one product is required.")
        }

        let player = Player(
            roleID: role.id,
            cash: role.cash,
            debt: role.debt,
            health: role.health,
            maxHealth: role.maxHealth,
            capacity: role.capacity,
            currentLocationID: role.startLocationID
        )

        return GameState(
            version: configuration.version,
            day: 1,
            maxDays: configuration.rules.maxDays,
            status: .inProgress,
            player: player,
            locations: configuration.locations,
            products: configuration.products,
            market: marketService.generateMarket(
                location: startLocation,
                products: configuration.products,
                rng: &rng
            ),
            activeNewsKey: configuration.news.first?.titleKey
        )
    }

    private func ensureGameIsActive() throws {
        guard state.status == .inProgress else {
            throw GameEngineError.gameAlreadyEnded
        }
    }

    private func refreshMarket() throws {
        guard let currentLocation = state.locations.first(where: { $0.id == state.player.currentLocationID }) else {
            throw GameEngineError.locationNotFound(state.player.currentLocationID)
        }

        state.market = marketService.generateMarket(
            location: currentLocation,
            products: state.products,
            rng: &rng
        )

        if !configuration.news.isEmpty {
            let index = rng.nextInt(in: 0...(configuration.news.count - 1))
            state.activeNewsKey = configuration.news[index].titleKey
        }
    }

    private func apply(event: GameEvent) throws {
        if let multiplier = event.effect.priceMultiplier {
            let targetIDs = priceEventTargets(for: event)
            state.market = state.market.map { price in
                guard targetIDs.contains(price.productID) else { return price }
                let adjusted = max(1, Int((Double(price.price) * multiplier).rounded()))
                return MarketPrice(
                    productID: price.productID,
                    locationID: price.locationID,
                    price: adjusted,
                    trendKey: multiplier >= 1 ? "trend.high" : "trend.low"
                )
            }
        }

        if let cashDelta = event.effect.cashDelta {
            state.player.cash = max(0, state.player.cash + cashDelta)
        }

        if let debtDelta = event.effect.debtDelta {
            state.player.debt = max(0, state.player.debt + debtDelta)
        }

        if let cashMultiplier = event.effect.cashMultiplier {
            state.player.cash = max(0, Int((Double(state.player.cash) * cashMultiplier).rounded()))
        }

        if let healthDelta = event.effect.healthDelta {
            state.player.health = min(
                state.player.maxHealth,
                max(0, state.player.health + healthDelta)
            )
        }

        if let percent = event.effect.inventoryLossPercent, percent > 0 {
            removeInventory(percent: percent)
        }

        if let productID = event.effect.bonusProductID,
           let quantity = event.effect.bonusQuantity,
           quantity > 0 {
            let acceptedQuantity = min(quantity, state.player.availableCapacity)
            if acceptedQuantity > 0 {
                state.player.addInventory(productID: productID, quantity: acceptedQuantity, unitPrice: 0)
            }
        }

        state.eventLog.append(
            EventLogEntry(
                day: state.day,
                eventID: event.id,
                type: event.type,
                titleKey: event.titleKey,
                bodyKey: event.bodyKey
            )
        )
    }

    private func priceEventTargets(for event: GameEvent) -> Set<String> {
        if let targetProductID = event.effect.targetProductID {
            return [targetProductID]
        }

        if let productIDs = event.productIDs, !productIDs.isEmpty {
            return Set(productIDs)
        }

        return Set(state.market.map(\.productID))
    }

    private func removeInventory(percent: Double) {
        let totalToLose = Int((Double(state.player.usedCapacity) * percent).rounded(.up))
        guard totalToLose > 0 else { return }

        for _ in 0..<totalToLose {
            guard !state.player.inventory.isEmpty else { return }
            let index = rng.nextInt(in: 0...(state.player.inventory.count - 1))
            state.player.inventory[index].quantity -= 1
            if state.player.inventory[index].quantity <= 0 {
                state.player.inventory.remove(at: index)
            }
        }
    }

    @discardableResult
    private func evaluateImmediateEndConditions() -> Bool {
        let ending = configuration.rules.endingConditions

        if state.player.health <= 0 {
            state.status = .lost
            state.ending = GameEnding(
                status: .lost,
                reasonKey: ending.healthFailureReasonKey,
                finalScore: finalScore()
            )
            return true
        }

        if state.player.debt >= ending.debtFailureLimit {
            state.status = .lost
            state.ending = GameEnding(
                status: .lost,
                reasonKey: ending.debtFailureReasonKey,
                finalScore: finalScore()
            )
            return true
        }

        return false
    }

    private func settleEndOfGame() {
        let ending = configuration.rules.endingConditions
        let score = finalScore()

        if score >= ending.victoryNetWorth {
            state.status = .won
            state.ending = GameEnding(
                status: .won,
                reasonKey: ending.victoryReasonKey,
                finalScore: score
            )
        } else {
            state.status = .lost
            state.ending = GameEnding(
                status: .lost,
                reasonKey: ending.brokeReasonKey,
                finalScore: score
            )
        }
    }

    private func finalScore() -> Int {
        state.player.netWorth(market: state.market)
    }
}
