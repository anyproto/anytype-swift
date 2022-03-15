import Foundation
import BlocksModels

protocol NewRelationOptionProtocol {
    
    var scope: RelationMetadata.Option.Scope { get }
    
}

extension Relation.Status.Option: NewRelationOptionProtocol {}
extension Relation.Tag.Option: NewRelationOptionProtocol {}
