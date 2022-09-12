import Foundation
import BlocksModels

protocol NewRelationOptionProtocol {
    
    var scope: RelationOption.Scope { get }
    
}

extension RelationValue.Status.Option: NewRelationOptionProtocol {}
extension RelationValue.Tag.Option: NewRelationOptionProtocol {}
