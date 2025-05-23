import UIKit

struct SlashMenuRealtionContentConfiguration: UIContentConfiguration, Hashable {
    var property: PropertyItemModel
    var currentConfigurationState: UICellConfigurationState?

    func makeContentView() -> any UIView & UIContentView {
        return SlashMenuRealtionView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> SlashMenuRealtionContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
