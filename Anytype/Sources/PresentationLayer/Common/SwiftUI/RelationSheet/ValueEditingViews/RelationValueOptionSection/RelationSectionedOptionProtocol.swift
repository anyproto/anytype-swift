import Foundation
import BlocksModels

protocol RelationSectionedOptionProtocol: Hashable {
    
    var text: String { get }
    var scope: RelationMetadata.Option.Scope { get }
    
}
