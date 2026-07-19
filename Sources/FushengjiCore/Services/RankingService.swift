import Foundation

public struct RankingEntry: Codable, Equatable, Identifiable {
    public var id: UUID
    public var playerName: String
    public var score: Int
    public var finishedAt: Date
    public var status: GameStatus

    public init(
        id: UUID = UUID(),
        playerName: String,
        score: Int,
        finishedAt: Date = Date(),
        status: GameStatus
    ) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.finishedAt = finishedAt
        self.status = status
    }
}

public final class RankingService {
    private let saveService: SaveGameService
    private let fileName = "rankings.json"

    public init(saveService: SaveGameService = SaveGameService()) {
        self.saveService = saveService
    }

    public func loadRankings() throws -> [RankingEntry] {
        let url = try rankingsURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode([RankingEntry].self, from: data)
    }

    public func record(_ entry: RankingEntry) throws {
        var rankings = try loadRankings()
        rankings.append(entry)
        rankings.sort { $0.score > $1.score }
        rankings = Array(rankings.prefix(10))

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(rankings)
        try data.write(to: try rankingsURL(), options: [.atomic])
    }

    private func rankingsURL() throws -> URL {
        let saveURL = try saveService.fileURL(for: "rankings-placeholder")
        let directory = saveURL.deletingLastPathComponent()
        return directory.appendingPathComponent(fileName)
    }
}
