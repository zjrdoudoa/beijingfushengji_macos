import SwiftUI
import FushengjiCore

struct InventoryView: View {
    let state: GameState

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(AppText.t("view.inventory"))
                    .font(.headline)

                Divider()

                if state.player.inventory.isEmpty {
                    Text(AppText.t("status.noInventory"))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(state.player.inventory) { item in
                        HStack {
                            Text(productName(for: item.productID))
                            Spacer()
                            Text("\(AppText.t("status.quantity")) \(item.quantity)")
                            Text("\(AppText.t("status.averageCost")) \(AppText.money(item.averageCost))")
                                .foregroundStyle(.secondary)
                        }
                        .font(.callout)
                    }
                }
            }
        }
    }

    private func productName(for productID: String) -> String {
        let key = state.products.first(where: { $0.id == productID })?.nameKey
        return AppText.t(key ?? productID)
    }
}
