import Foundation
import SwiftUI
import BlocksModels
import MobileCoreServices

struct DividerBlockContentConfiguration: UIContentConfiguration, Hashable {
    let content: BlockDivider
    private(set) var currentConfigurationState: UICellConfigurationState?
    
    // MARK:  - UIContentConfiguration
    func makeContentView() -> UIView & UIContentView {
        return DividerBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}
