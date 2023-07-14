import Foundation
import SwiftProtobuf

public protocol RelationsServiceProtocol: AnyObject {
    func addFeaturedRelation(relationKey: String) async throws
    func removeFeaturedRelation(relationKey: String) async throws
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value) async throws

    func createRelation(relationDetails: RelationDetails) async throws -> RelationDetails?
    func addRelations(relationsDetails: [RelationDetails]) async throws
    func addRelations(relationKeys: [String]) async throws

    func removeRelation(relationKey: String) async throws
    func addRelationOption(relationKey: String, optionText: String) async throws -> String?
}
