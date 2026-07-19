import SwiftUI

struct StartMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(AppText.t("app.title"))
                    .font(.system(.largeTitle, design: .serif))
                    .fontWeight(.semibold)

                Text(AppText.t("app.subtitle"))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 520)
            }

            VStack(spacing: 12) {
                Button(AppText.t("action.newGame")) {
                    viewModel.newGame()
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)

                Button(AppText.t("action.load")) {
                    viewModel.loadGame()
                }
            }

            Text(AppText.t("app.prototypeNote"))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}
