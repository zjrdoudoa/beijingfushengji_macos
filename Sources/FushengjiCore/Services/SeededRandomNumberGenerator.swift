import Foundation

public struct SeededRandomNumberGenerator: RandomNumberGenerator, Codable, Equatable {
    public private(set) var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    public init(restoringState state: UInt64) {
        self.state = state == 0 ? 0x9E37_79B9_7F4A_7C15 : state
    }

    public mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }

    public mutating func nextDouble() -> Double {
        let value = next() >> 11
        return Double(value) / 9_007_199_254_740_992.0
    }

    public mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        let lower = range.lowerBound
        let upper = range.upperBound
        guard upper > lower else { return lower }

        let span = UInt64(upper - lower + 1)
        return lower + Int(next() % span)
    }
}
