import UIKit
import BlocksModels

struct BlockBookmarkConfiguration: UIContentConfiguration, Hashable {
    
    let information: BlockInformation
    
    weak var contextMenuHolder: BlockBookmarkViewModel?
    
    init(_ information: BlockInformation) {
        switch information.content {
        case .bookmark: break
        default:
            assertionFailure("Can't create content configuration for content: \(information.content)")
            break
        }
        
        self.information = information
    }
            
    func makeContentView() -> UIView & UIContentView {
        BlockBookmarkContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockBookmarkConfiguration {
        return self
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.information == rhs.information &&
            lhs.information.content == rhs.information.content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information)
        hasher.combine(information.content)
    }
    
}
