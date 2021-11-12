import UIKit

struct FeaturedRelationsBlockContentConfiguration: BlockConfigurationProtocol, Hashable {        
    let type: String
    let alignment: NSTextAlignment
    var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        FeaturedRelationsBlockView(configuration: self)
    }
}
