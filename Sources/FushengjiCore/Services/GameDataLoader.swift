import Foundation

public enum GameDataLoader {
    public static func loadDefaultConfiguration() throws -> GameConfiguration {
        try loadDefaultConfiguration(bundle: .module)
    }

    public static func loadDefaultConfiguration(bundle: Bundle) throws -> GameConfiguration {
        let url = bundle.url(
            forResource: "GameConfiguration",
            withExtension: "json",
            subdirectory: "GameData"
        ) ?? bundle.url(
            forResource: "GameConfiguration",
            withExtension: "json"
        )

        guard let url else {
            throw GameEngineError.configurationNotFound
        }

        return try loadConfiguration(from: url)
    }

    public static func loadConfiguration(from url: URL) throws -> GameConfiguration {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(GameConfiguration.self, from: data)
    }
}
