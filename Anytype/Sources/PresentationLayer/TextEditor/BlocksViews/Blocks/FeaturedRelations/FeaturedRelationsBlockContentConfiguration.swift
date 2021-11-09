import UIKit

struct FeaturedRelationsBlockContentConfiguration: UIContentConfiguration, Hashable {
        
    let type: String
    let alignment: NSTextAlignment
    private(set) var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        FeaturedRelationsBlockView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }
}

