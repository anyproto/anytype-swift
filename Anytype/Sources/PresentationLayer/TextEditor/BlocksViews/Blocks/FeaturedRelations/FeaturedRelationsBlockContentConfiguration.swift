import UIKit

struct FeaturedRelationsBlockContentConfiguration: AnytypeBlockContentConfigurationProtocol, Hashable {        
    let type: String
    let alignment: NSTextAlignment
    var currentConfigurationState: UICellConfigurationState?
    
    func makeContentView() -> UIView & UIContentView {
        FeaturedRelationsBlockView(configuration: self)
    }
}
