import Foundation
import SwiftUI
import FushengjiCore

enum AppPhase {
    case startMenu
    case playing
    case ended
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var phase: AppPhase = .startMenu
    @Published private(set) var state: GameState
    @Published var selectedQuantity: Int = 1
    @Published var soundEnabled: Bool = true {
        didSet { soundService.isEnabled = soundEnabled }
    }
    @Published var lastMessage: String?

    private let configuration: GameConfiguration
    private var engine: GameEngine
    private let saveService: SaveGameService
    private let rankingService: RankingService
    private let soundService: SoundService
    private var didRecordEnding = false

    init() {
        do {
            let configuration = try GameDataLoader.loadDefaultConfiguration()
            let saveService = SaveGameService()
            let engine = try GameEngine(configuration: configuration, seed: Self.makeSeed())

            self.configuration = configuration
            self.engine = engine
            self.state = engine.state
            self.saveService = saveService
            self.rankingService = RankingService(saveService: saveService)
            self.soundService = SoundService()
        } catch {
            fatalError("Failed to load game configuration: \(error)")
        }
    }

    func showStartMenu() {
        phase = .startMenu
    }

    func newGame() {
        do {
            try engine.newGame(seed: Self.makeSeed())
            didRecordEnding = false
            syncState()
            phase = .playing
            lastMessage = AppText.t("message.newGame")
        } catch {
            lastMessage = error.localizedDescription
        }
    }

    func saveGame() {
        do {
            let saveGame = engine.makeSaveGame(slot: "autosave")
            try saveService.save(saveGame)
            lastMessage = AppText.t("message.saved")
        } catch {
            lastMessage = AppText.format("message.saveFailed", error.localizedDescription)
        }
    }

    func loadGame() {
        do {
            let saveGame = try saveService.load(slot: "autosave")
            engine = GameEngine(configuration: configuration, saveGame: saveGame)
            didRecordEnding = saveGame.state.status != .inProgress
            syncState()
            phase = state.status == .inProgress ? .playing : .ended
            lastMessage = AppText.t("message.loaded")
        } catch {
            lastMessage = AppText.format("message.loadFailed", error.localizedDescription)
        }
    }

    func buy(productID: String) {
        perform(.buy) {
            try engine.buy(productID: productID, quantity: selectedQuantity)
        }
    }

    func sell(productID: String) {
        perform(.sell) {
            try engine.sell(productID: productID, quantity: selectedQuantity)
        }
    }

    func travel(to locationID: String) {
        perform(.travel) {
            try engine.travel(to: locationID)
        }
    }

    func repayDebt() {
        perform(nil) {
            try engine.repayDebt(amount: 1_000)
        }
    }

    func borrowDebt() {
        perform(nil) {
            try engine.borrow(amount: 1_000)
        }
    }

    func dismissMessage() {
        lastMessage = nil
    }

    private func perform(_ soundCue: SoundCue?, action: () throws -> Void) {
        do {
            try action()
            syncState()
            if let soundCue {
                soundService.play(soundCue)
            }
            handleEndingIfNeeded()
        } catch {
            lastMessage = error.localizedDescription
        }
    }

    private func syncState() {
        state = engine.state
    }

    private func handleEndingIfNeeded() {
        guard state.status != .inProgress else { return }
        phase = .ended

        guard !didRecordEnding, let ending = state.ending else { return }
        didRecordEnding = true

        try? rankingService.record(
            RankingEntry(
                playerName: AppText.t("role.runner"),
                score: ending.finalScore,
                status: state.status
            )
        )
        soundService.play(.gameOver)
    }

    private static func makeSeed() -> UInt64 {
        UInt64(Date().timeIntervalSince1970 * 1_000)
    }
}
