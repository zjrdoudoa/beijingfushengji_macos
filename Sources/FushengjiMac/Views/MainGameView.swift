import SwiftUI

struct MainGameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            PlayerStatusView(state: viewModel.state)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider()

            HSplitView {
                VStack(spacing: 12) {
                    MarketView(viewModel: viewModel)
                    TravelView(viewModel: viewModel)
                }
                .frame(minWidth: 520)
                .padding()

                VStack(spacing: 12) {
                    InventoryView(state: viewModel.state)
                    BankDebtView(viewModel: viewModel)
                    EventLogView(state: viewModel.state)
                }
                .frame(minWidth: 360)
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(AppText.t("action.save")) {
                    viewModel.saveGame()
                }

                Button(AppText.t("action.newGame")) {
                    viewModel.newGame()
                }
            }
        }
    }
}
