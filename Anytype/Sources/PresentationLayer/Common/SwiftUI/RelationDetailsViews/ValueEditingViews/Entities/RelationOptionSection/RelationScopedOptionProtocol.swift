import Foundation
import BlocksModels

protocol RelationScopedOptionProtocol: Hashable {
    
    var scope: RelationMetadata.Option.Scope { get }
    
}

extension Relation.Status.Option: RelationScopedOptionProtocol {}
extension Relation.Tag.Option: RelationScopedOptionProtocol {}
