import Foundation
import SwiftProtobuf

public protocol PropertiesServiceProtocol: AnyObject, Sendable {
    func setFeaturedProperty(objectId: String, featuredPropertyIds: [String]) async throws
    
    func updateProperty(objectId: String, propertyKey: String, value: Google_Protobuf_Value) async throws
    func updateProperty(objectId: String, fields: [String: Google_Protobuf_Value]) async throws
    func updatePropertyOption(id: String, text: String, color: String?) async throws

    func createProperty(spaceId: String, propertyDetails: RelationDetails) async throws -> RelationDetails
    func addProperties(objectId: String, propertiesDetails: [RelationDetails]) async throws
    func addProperties(objectId: String, propertyKeys: [String]) async throws

    func removeProperty(objectId: String, propertyKey: String) async throws
    func removeProperties(objectId: String, propertyKeys: [String]) async throws
    
    func addPropertyOption(spaceId: String, propertyKey: String, optionText: String, color: String?) async throws -> String?
    func removePropertyOptions(ids: [String]) async throws
    
    // New api
    func updateTypeProperties(
        typeId: String,
        dataviewId: String,
        recommendedProperties: [RelationDetails],
        recommendedFeaturedProperties: [RelationDetails],
        recommendedHiddenProperties: [RelationDetails]
    ) async throws
    func getConflictPropertiesForType(typeId: String, spaceId: String) async throws -> [String]
    
    func toggleDescription(objectId: String, isOn: Bool) async throws
}
