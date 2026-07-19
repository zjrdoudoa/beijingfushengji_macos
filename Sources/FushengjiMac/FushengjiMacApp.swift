import SwiftUI

@main
struct FushengjiMacApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup(AppText.t("app.title")) {
            RootView(viewModel: viewModel)
                .frame(minWidth: 980, minHeight: 680)
        }
        .commands {
            CommandMenu(AppText.t("menu.game")) {
                Button(AppText.t("menu.newGame")) {
                    viewModel.newGame()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button(AppText.t("menu.save")) {
                    viewModel.saveGame()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button(AppText.t("menu.load")) {
                    viewModel.loadGame()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }

        Settings {
            SettingsView(viewModel: viewModel)
                .padding()
                .frame(width: 420)
        }
    }
}
