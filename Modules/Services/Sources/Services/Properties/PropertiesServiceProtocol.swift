import Foundation
import SwiftProtobuf

public protocol PropertiesServiceProtocol: AnyObject, Sendable {
    func setFeaturedRelation(objectId: String, featuredRelationIds: [String]) async throws
    
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
    func updateTypeRelations(
        typeId: String,
        dataviewId: String,
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails]
    ) async throws
    func getConflictRelationsForType(typeId: String, spaceId: String) async throws -> [String]
    
    func toggleDescription(objectId: String, isOn: Bool) async throws
}
