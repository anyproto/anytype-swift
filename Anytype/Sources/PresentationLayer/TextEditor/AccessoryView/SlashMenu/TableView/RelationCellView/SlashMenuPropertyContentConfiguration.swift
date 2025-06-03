import UIKit

struct SlashMenuPropertyContentConfiguration: UIContentConfiguration, Hashable {
    var property: PropertyItemModel
    var currentConfigurationState: UICellConfigurationState?

    func makeContentView() -> any UIView & UIContentView {
        return SlashMenuPropertyView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> SlashMenuPropertyContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
