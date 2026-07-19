import SwiftUI
import FushengjiCore

struct MarketView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                HStack {
                    Text(AppText.t("view.market"))
                        .font(.headline)
                    Spacer()
                    Stepper(
                        AppText.format("settings.quantityValue", viewModel.selectedQuantity),
                        value: $viewModel.selectedQuantity,
                        in: 1...20
                    )
                    .frame(width: 150)
                }

                Divider()

                ForEach(viewModel.state.products) { product in
                    marketRow(product)
                    if product.id != viewModel.state.products.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    private func marketRow(_ product: Product) -> some View {
        let price = viewModel.state.market.first(where: { $0.productID == product.id })

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(AppText.t(product.nameKey))
                    .font(.body)
                Text("\(AppText.t(product.unitKey)) · \(AppText.t("status.risk")) \(product.riskLevel)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(AppText.money(price?.price ?? 0))
                    .font(.system(.body, design: .monospaced))
                if let trend = price?.trendKey {
                    Text(AppText.t(trend))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button(AppText.t("action.buy")) {
                viewModel.buy(productID: product.id)
            }

            Button(AppText.t("action.sell")) {
                viewModel.sell(productID: product.id)
            }
        }
        .padding(.vertical, 4)
    }
}
