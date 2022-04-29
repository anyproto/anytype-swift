import UIKit

struct SlashMenuRealtionContentConfiguration: UIContentConfiguration, Hashable {
    var relation: RelationItemModel
    var currentConfigurationState: UICellConfigurationState?

    func makeContentView() -> UIView & UIContentView {
        return SlashMenuRealtionView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> SlashMenuRealtionContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
