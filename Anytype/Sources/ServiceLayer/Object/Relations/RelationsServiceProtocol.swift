import Foundation
import BlocksModels
import SwiftProtobuf

protocol RelationsServiceProtocol: AnyObject {
    func addFeaturedRelation(relationKey: String)
    func removeFeaturedRelation(relationKey: String)
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value)

    func createRelation(relationDetails: RelationDetails) -> RelationDetails?
    func addRelations(relationsDetails: [RelationDetails]) -> Bool
    func addRelations(relationKeys: [String]) -> Bool

    func removeRelation(relationKey: String)
    func addRelationOption(relationKey: String, optionText: String) -> String?
    func availableRelations() -> [RelationDetails]
}
