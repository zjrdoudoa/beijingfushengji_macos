import SwiftUI
import FushengjiCore

struct EventLogView: View {
    let state: GameState

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(AppText.t("view.events"))
                    .font(.headline)

                if let news = state.activeNewsKey {
                    Text("\(AppText.t("status.news"))：\(AppText.t(news))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Divider()

                if state.eventLog.isEmpty {
                    Text(AppText.t("status.noEvents"))
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(state.eventLog.reversed()) { entry in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(AppText.format("status.dayValue", entry.day, state.maxDays))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(AppText.t(entry.titleKey))
                                        .font(.callout)
                                        .fontWeight(.medium)
                                    Text(AppText.t(entry.bodyKey))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxHeight: 180)
                }
            }
        }
    }
}
