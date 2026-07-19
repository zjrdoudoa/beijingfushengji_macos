import SwiftUI
import FushengjiCore

struct TravelView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(AppText.t("view.travel"))
                    .font(.headline)

                Divider()

                ForEach(viewModel.state.locations) { location in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(AppText.t(location.nameKey))
                            Text("\(AppText.t("status.travelCost")) \(AppText.money(location.travelCost))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(AppText.t("action.travel")) {
                            viewModel.travel(to: location.id)
                        }
                        .disabled(location.id == viewModel.state.player.currentLocationID)
                    }
                    .padding(.vertical, 3)
                }
            }
        }
    }
}
