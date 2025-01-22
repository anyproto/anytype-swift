import Foundation
import SwiftProtobuf

public protocol RelationsServiceProtocol: AnyObject, Sendable {
    func addFeaturedRelation(objectId: String, relationKey: String) async throws
    func removeFeaturedRelation(objectId: String, relationKey: String) async throws
    
    func updateRelation(objectId: String, relationKey: String, value: Google_Protobuf_Value) async throws
    func updateRelation(objectId: String, fields: [String: Google_Protobuf_Value]) async throws
    func updateRelationOption(id: String, text: String, color: String?) async throws

    func createRelation(spaceId: String, relationDetails: RelationDetails) async throws -> RelationDetails
    func addRelations(objectId: String, relationsDetails: [RelationDetails]) async throws
    func addRelations(objectId: String, relationKeys: [String]) async throws

    func removeRelation(objectId: String, relationKey: String) async throws
    func removeRelations(objectId: String, relationKeys: [String]) async throws
    
    func addRelationOption(spaceId: String, relationKey: String, optionText: String, color: String?) async throws -> String?
    func removeRelationOptions(ids: [String]) async throws
    
    // New api
    func updateTypeRelations(typeId: String, recommendedRelationIds: [ObjectId], recommendedFeaturedRelationsIds: [ObjectId]) async throws
    func updateRecommendedRelations(typeId: String, relationIds: [ObjectId]) async throws
    func updateRecommendedFeaturedRelations(typeId: String, relationIds: [ObjectId]) async throws
    func getConflictRelationsForType(typeId: String, spaceId: String) async throws -> [String]
}
