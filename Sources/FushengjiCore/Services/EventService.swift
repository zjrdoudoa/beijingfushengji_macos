import Foundation

public final class EventService {
    public init() {}

    public func rollEvent(
        for state: GameState,
        events: [GameEvent],
        rng: inout SeededRandomNumberGenerator
    ) -> GameEvent? {
        let candidates = events.filter { event in
            guard event.probability > 0 else { return false }

            if let locationIDs = event.locationIDs, !locationIDs.contains(state.player.currentLocationID) {
                return false
            }

            if let productIDs = event.productIDs {
                let visibleProductIDs = Set(state.market.map(\.productID))
                return !visibleProductIDs.isDisjoint(with: productIDs)
            }

            return true
        }

        guard !candidates.isEmpty else { return nil }

        let roll = rng.nextDouble()
        var threshold = 0.0

        for event in candidates {
            threshold += event.probability
            if roll < threshold {
                return event
            }
        }

        return nil
    }
}
