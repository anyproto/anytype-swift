import UIKit

protocol AnytypeBlockContentConfigurationProtocol: UIContentConfiguration {
    var currentConfigurationState: UICellConfigurationState? { get set }
}

extension UIContentConfiguration where Self: AnytypeBlockContentConfigurationProtocol {
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
