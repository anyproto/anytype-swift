import Foundation
import BlocksModels
import SwiftProtobuf

protocol RelationsServiceProtocol {
    func addFeaturedRelation(relationKey: String)
    func removeFeaturedRelation(relationKey: String)
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value)
    
    func removeRelation(relationKey: String)
    func addRelationOption(relationKey: String, optionText: String) -> String?
    func availableRelations() -> [RelationMetadata]?
}
