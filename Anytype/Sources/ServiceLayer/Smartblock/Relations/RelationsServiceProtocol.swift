import Foundation
import BlocksModels
import SwiftProtobuf

enum RelationSource {
    case object
    case dataview(recordId: BlockId)
}

protocol RelationsServiceProtocol {
    func addFeaturedRelation(relationKey: String)
    func removeFeaturedRelation(relationKey: String)
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value)

    func createRelation(source: RelationSource, relation: RelationMetadata) -> RelationMetadata?
    func addRelation(source: RelationSource, relation: RelationMetadata) -> RelationMetadata?

    func removeRelation(source: RelationSource, relationKey: String)
    func addRelationOption(source: RelationSource, relationKey: String, optionText: String) -> String?
    func availableRelations(source: RelationSource) -> [RelationMetadata]?
}
