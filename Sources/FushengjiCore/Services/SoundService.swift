import Foundation

public enum SoundCue: String, Codable, Equatable {
    case buy
    case sell
    case travel
    case event
    case gameOver
}

public final class SoundService {
    public var isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func play(_ cue: SoundCue) {
        guard isEnabled else { return }
        // Intentionally a no-op in the core module. A future AppKit adapter can map cues to bundled sounds.
        _ = cue
    }
}
