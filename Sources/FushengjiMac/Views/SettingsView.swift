import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Form {
            Toggle(AppText.t("settings.sound"), isOn: $viewModel.soundEnabled)

            Stepper(
                AppText.format("settings.quantityValue", viewModel.selectedQuantity),
                value: $viewModel.selectedQuantity,
                in: 1...20
            )
        }
        .navigationTitle(AppText.t("view.settings"))
    }
}
