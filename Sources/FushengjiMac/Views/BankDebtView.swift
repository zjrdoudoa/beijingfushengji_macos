import SwiftUI

struct BankDebtView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text(AppText.t("view.bank"))
                    .font(.headline)

                HStack {
                    Text(AppText.t("status.debt"))
                    Spacer()
                    Text(AppText.money(viewModel.state.player.debt))
                        .font(.system(.body, design: .monospaced))
                }

                HStack {
                    Button(AppText.t("action.repay")) {
                        viewModel.repayDebt()
                    }
                    Button(AppText.t("action.borrow")) {
                        viewModel.borrowDebt()
                    }
                }
            }
        }
    }
}
