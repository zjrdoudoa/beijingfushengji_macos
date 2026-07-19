import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        content
            .background(Color(nsColor: .windowBackgroundColor))
            .alert(
                AppText.t("alert.message"),
                isPresented: Binding(
                    get: { viewModel.lastMessage != nil },
                    set: { if !$0 { viewModel.dismissMessage() } }
                )
            ) {
                Button(AppText.t("action.dismiss")) {
                    viewModel.dismissMessage()
                }
            } message: {
                Text(viewModel.lastMessage ?? "")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .startMenu:
            StartMenuView(viewModel: viewModel)
        case .playing:
            MainGameView(viewModel: viewModel)
        case .ended:
            EndGameView(viewModel: viewModel)
        }
    }
}
