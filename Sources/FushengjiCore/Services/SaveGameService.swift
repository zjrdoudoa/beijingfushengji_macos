import Foundation

public final class SaveGameService {
    private let fileManager: FileManager
    private let baseDirectory: URL?
    private let directoryName: String

    public init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil,
        directoryName: String? = nil
    ) {
        self.fileManager = fileManager
        self.baseDirectory = baseDirectory
        self.directoryName = directoryName
            ?? Bundle.main.bundleIdentifier
            ?? "BeijingFushengjiMac"
    }

    @discardableResult
    public func save(_ saveGame: SaveGame, slot: String? = nil) throws -> SaveGame {
        var copy = saveGame
        copy.slot = slot ?? saveGame.slot
        copy.updatedAt = Date()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .secondsSince1970

        let data = try encoder.encode(copy)
        let url = try fileURL(for: copy.slot)
        try data.write(to: url, options: [.atomic])
        return copy
    }

    @discardableResult
    public func save(state: GameState, seedState: UInt64, slot: String = "autosave") throws -> SaveGame {
        let saveGame = SaveGame(
            slot: slot,
            appVersion: "0.1.0",
            seedState: seedState,
            state: state
        )
        return try save(saveGame)
    }

    public func load(slot: String = "autosave") throws -> SaveGame {
        let data = try Data(contentsOf: try fileURL(for: slot))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(SaveGame.self, from: data)
    }

    public func listSaves() throws -> [SaveGame] {
        let directory = try supportDirectory()
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return urls
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return try? decoder.decode(SaveGame.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    public func delete(slot: String) throws {
        let url = try fileURL(for: slot)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    public func fileURL(for slot: String) throws -> URL {
        try supportDirectory()
            .appendingPathComponent("\(sanitizedSlot(slot)).json", isDirectory: false)
    }

    private func supportDirectory() throws -> URL {
        let root: URL

        if let baseDirectory {
            root = baseDirectory
        } else {
            root = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent(directoryName, isDirectory: true)
        }

        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    private func sanitizedSlot(_ slot: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = slot.unicodeScalars.map { scalar -> Character in
            allowed.contains(scalar) ? Character(scalar) : "-"
        }
        let cleaned = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: "-_"))
        return cleaned.isEmpty ? "autosave" : cleaned
    }
}
