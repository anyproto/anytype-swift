import UIKit

struct FeaturedRelationsBlockContentConfiguration: UIContentConfiguration, Hashable {
        
    let type: String
    let alignment: NSTextAlignment
    
    func makeContentView() -> UIView & UIContentView {
        FeaturedRelationsBlockView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

