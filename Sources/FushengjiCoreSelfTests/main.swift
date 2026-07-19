import Foundation
import FushengjiCore

@main
struct SelfTestRunner {
    static func main() throws {
        let tests: [(String, () throws -> Void)] = [
            ("default configuration loading", testDefaultConfigurationLoads),
            ("initialization", testInitializationBuildsPlayerAndMarket),
            ("daily interest", testDailyInterestAccruesDebt),
            ("buy and sell", testBuyingAndSellingProductsUpdatesCashAndInventory),
            ("travel cost", testTravelConsumesCashHealthAndDay),
            ("random event", testRandomPriceEventAdjustsMarket),
            ("debt failure", testDebtFailureAfterInterest),
            ("victory settlement", testVictorySettlementAfterDayLimit),
            ("save round trip", testSaveGameRoundTrip)
        ]

        for (name, test) in tests {
            try test()
            print("PASS \(name)")
        }

        print("PASS \(tests.count) core self-tests")
    }
}

private struct TestFailure: Error, CustomStringConvertible {
    var description: String
}

private func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else {
        throw TestFailure(description: message)
    }
}

private func testInitializationBuildsPlayerAndMarket() throws {
    let engine = try GameEngine(configuration: testConfiguration(), seed: 42)

    try expect(engine.state.day == 1, "initial day")
    try expect(engine.state.maxDays == 40, "max days")
    try expect(engine.state.player.cash == 1_000, "initial cash")
    try expect(engine.state.player.debt == 100, "initial debt")
    try expect(engine.state.player.currentLocationID == "a", "start location")
    try expect(engine.state.market.count == 1, "market count")
    try expect(engine.state.market.first?.price == 10, "initial market price")
}

private func testDefaultConfigurationLoads() throws {
    let configuration = try GameDataLoader.loadDefaultConfiguration()

    try expect(configuration.rules.maxDays == 40, "default max days")
    try expect(!configuration.locations.isEmpty, "default locations")
    try expect(!configuration.products.isEmpty, "default products")
    try expect(!configuration.events.isEmpty, "default events")
}

private func testDailyInterestAccruesDebt() throws {
    let engine = try GameEngine(
        configuration: testConfiguration(startDebt: 1_000, interest: 0.10),
        seed: 7
    )

    try engine.advanceDay(applyRandomEvent: false)

    try expect(engine.state.player.debt == 1_100, "debt after interest")
}

private func testBuyingAndSellingProductsUpdatesCashAndInventory() throws {
    let engine = try GameEngine(configuration: testConfiguration(startDebt: 0), seed: 7)

    try engine.buy(productID: "p1", quantity: 5)
    try expect(engine.state.player.cash == 950, "cash after buy")
    try expect(engine.state.player.quantity(of: "p1") == 5, "inventory after buy")
    try expect(engine.state.player.inventory.first?.averageCost == 10, "average cost")

    try engine.sell(productID: "p1", quantity: 2)
    try expect(engine.state.player.cash == 970, "cash after sell")
    try expect(engine.state.player.quantity(of: "p1") == 3, "inventory after sell")
}

private func testTravelConsumesCashHealthAndDay() throws {
    let engine = try GameEngine(
        configuration: testConfiguration(startDebt: 0, travelHealthCost: 3),
        seed: 9
    )

    try engine.travel(to: "b")

    try expect(engine.state.day == 2, "day after travel")
    try expect(engine.state.player.currentLocationID == "b", "location after travel")
    try expect(engine.state.player.cash == 993, "cash after travel")
    try expect(engine.state.player.health == 97, "health after travel")
}

private func testRandomPriceEventAdjustsMarket() throws {
    let event = GameEvent(
        id: "fixed-price-event",
        type: .price,
        titleKey: "event.test.title",
        bodyKey: "event.test.body",
        probability: 1.0,
        productIDs: ["p1"],
        effect: GameEventEffect(targetProductID: "p1", priceMultiplier: 2.0)
    )
    let engine = try GameEngine(
        configuration: testConfiguration(startDebt: 0, events: [event]),
        seed: 11
    )

    try engine.advanceDay()

    try expect(engine.state.market.first?.price == 20, "price event adjustment")
    try expect(engine.state.eventLog.count == 1, "event log count")
    try expect(engine.state.eventLog.first?.eventID == "fixed-price-event", "event id")
}

private func testDebtFailureAfterInterest() throws {
    let engine = try GameEngine(
        configuration: testConfiguration(
            startDebt: 1_000,
            interest: 0.10,
            debtFailureLimit: 1_050
        ),
        seed: 13
    )

    try engine.advanceDay(applyRandomEvent: false)

    try expect(engine.state.status == .lost, "debt failure status")
    try expect(engine.state.ending?.reasonKey == "ending.debtFailure", "debt failure reason")
}

private func testVictorySettlementAfterDayLimit() throws {
    let engine = try GameEngine(
        configuration: testConfiguration(
            maxDays: 1,
            startCash: 2_000,
            startDebt: 0,
            victoryNetWorth: 1_000
        ),
        seed: 17
    )

    try engine.advanceDay(applyRandomEvent: false)

    try expect(engine.state.status == .won, "victory status")
    try expect(engine.state.ending?.reasonKey == "ending.victory", "victory reason")
    try expect(engine.state.ending?.finalScore == 2_000, "victory score")
}

private func testSaveGameRoundTrip() throws {
    let engine = try GameEngine(configuration: testConfiguration(startDebt: 0), seed: 19)
    try engine.buy(productID: "p1", quantity: 2)

    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FushengjiCoreSelfTests-\(UUID().uuidString)", isDirectory: true)
    let service = SaveGameService(baseDirectory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }

    let saved = try service.save(
        state: engine.state,
        seedState: engine.seedState,
        slot: "unit-test"
    )
    let loaded = try service.load(slot: "unit-test")

    try expect(saved.slot == "unit-test", "save slot")
    try expect(loaded.seedState == engine.seedState, "seed round trip")
    try expect(loaded.state == engine.state, "state round trip")
}

private func testConfiguration(
    maxDays: Int = 40,
    startCash: Int = 1_000,
    startDebt: Int = 100,
    interest: Double = 0.05,
    travelHealthCost: Int = 2,
    debtFailureLimit: Int = 10_000,
    victoryNetWorth: Int = 5_000,
    events: [GameEvent] = []
) -> GameConfiguration {
    let product = Product(
        id: "p1",
        nameKey: "product.test",
        category: "test",
        unitKey: "unit.test",
        basePrice: 10,
        minPrice: 10,
        maxPrice: 10,
        riskLevel: 1
    )

    let locations = [
        Location(id: "a", nameKey: "location.a", travelCost: 0, marketModifiers: ["p1": 1.0]),
        Location(id: "b", nameKey: "location.b", travelCost: 7, marketModifiers: ["p1": 1.0])
    ]

    let endings = EndingConditions(
        debtFailureLimit: debtFailureLimit,
        victoryNetWorth: victoryNetWorth,
        victoryReasonKey: "ending.victory",
        debtFailureReasonKey: "ending.debtFailure",
        healthFailureReasonKey: "ending.healthFailure",
        brokeReasonKey: "ending.broke"
    )

    let rules = GameRules(
        defaultRoleID: "tester",
        maxDays: maxDays,
        debtInterestRate: interest,
        travelHealthCost: travelHealthCost,
        maxBorrowAmount: debtFailureLimit,
        endingConditions: endings
    )

    let role = RoleStatusConfig(
        id: "tester",
        nameKey: "role.tester",
        cash: startCash,
        debt: startDebt,
        health: 100,
        maxHealth: 100,
        capacity: 20,
        startLocationID: "a"
    )

    return GameConfiguration(
        version: 1,
        rules: rules,
        roles: [role],
        locations: locations,
        products: [product],
        events: events,
        news: []
    )
}
