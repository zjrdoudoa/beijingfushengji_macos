import SwiftUI
import FushengjiCore

struct PlayerStatusView: View {
    let state: GameState

    var body: some View {
        HStack(spacing: 18) {
            statusItem(AppText.t("status.day"), value: AppText.format("status.dayValue", state.day, state.maxDays))
            statusItem(AppText.t("status.location"), value: currentLocationName)
            statusItem(AppText.t("status.cash"), value: AppText.money(state.player.cash))
            statusItem(AppText.t("status.debt"), value: AppText.money(state.player.debt))
            statusItem(AppText.t("status.health"), value: "\(state.player.health)/\(state.player.maxHealth)")
            statusItem(AppText.t("status.capacity"), value: "\(state.player.usedCapacity)/\(state.player.capacity)")
            statusItem(AppText.t("status.netWorth"), value: AppText.money(state.player.netWorth(market: state.market)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var currentLocationName: String {
        let key = state.locations.first(where: { $0.id == state.player.currentLocationID })?.nameKey
        return AppText.t(key ?? state.player.currentLocationID)
    }

    private func statusItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }
}
