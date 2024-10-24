import UIKit

struct UISectionHeaderConfiguration: UIContentConfiguration, Hashable {
    let title: String
    
    func makeContentView() -> any UIView & UIContentView {
        UISectionHeader(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> UISectionHeaderConfiguration {
        self
    }
}
