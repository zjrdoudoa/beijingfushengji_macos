import SwiftUI

struct EndGameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(AppText.t("status.ended"))
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.semibold)

            if let ending = viewModel.state.ending {
                Text(AppText.t(ending.reasonKey))
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)

                Text("\(AppText.t("status.finalScore"))：\(AppText.money(ending.finalScore))")
                    .font(.system(.title3, design: .monospaced))
            }

            HStack {
                Button(AppText.t("action.newGame")) {
                    viewModel.newGame()
                }
                .keyboardShortcut(.defaultAction)

                Button(AppText.t("action.backToMenu")) {
                    viewModel.showStartMenu()
                }
            }
        }
        .padding(40)
    }
}
