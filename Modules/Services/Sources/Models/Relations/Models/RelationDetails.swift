import Foundation
import SwiftProtobuf

public struct RelationDetails: Hashable, Sendable {

    public let id: String
    public let key: String
    public let name: String
    public let format: RelationFormat
    public let isHidden: Bool
    public let isReadOnly: Bool
    public let isReadOnlyValue: Bool
    public let objectTypes: [String]
    public let maxCount: Int
    public let sourceObject: String
    public let isDeleted: Bool
    public let spaceId: String
    
    public init(
        id: String,
        key: String,
        name: String,
        format: RelationFormat,
        isHidden: Bool,
        isReadOnly: Bool,
        isReadOnlyValue: Bool,
        objectTypes: [String],
        maxCount: Int,
        sourceObject: String,
        isDeleted: Bool,
        spaceId: String
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.format = format
        self.isHidden = isHidden
        self.isReadOnly = isReadOnly
        self.isReadOnlyValue = isReadOnlyValue
        self.objectTypes = objectTypes
        self.maxCount = maxCount
        self.sourceObject = sourceObject
        self.isDeleted = isDeleted
        self.spaceId = spaceId
    }
}

extension RelationDetails: DetailsModel {
    
    public init(details: ObjectDetails) {
        self.id = details.id
        self.key = details.relationKey
        self.name = details.name
        self.format = details.relationFormatValue
        self.isHidden = details.isHidden
        self.isReadOnly = details.isReadonly
        self.isReadOnlyValue = details.relationReadonlyValue
        self.objectTypes = details.relationFormatObjectTypes
        self.maxCount = details.relationMaxCount ?? 0
        self.sourceObject = details.sourceObject
        self.isDeleted = details.isDeleted
        self.spaceId = details.spaceId
    }
    
    public static var subscriptionKeys: [BundledRelationKey] {
        return [
            BundledRelationKey.id,
            BundledRelationKey.relationKey,
            BundledRelationKey.name,
            BundledRelationKey.relationFormat,
            BundledRelationKey.relationReadonlyValue,
            BundledRelationKey.relationFormatObjectTypes,
            BundledRelationKey.isHidden,
            BundledRelationKey.isReadonly,
            BundledRelationKey.relationMaxCount,
            BundledRelationKey.sourceObject,
            BundledRelationKey.spaceId
        ]
    }
    
    public var asMiddleware: Google_Protobuf_Struct {
        return Google_Protobuf_Struct(fields: fields)
    }
    
    public var fields: [String: Google_Protobuf_Value] {
        var fields = [String: Google_Protobuf_Value]()
        if name.isNotEmpty {
            fields[BundledRelationKey.name.rawValue] = name.protobufValue
        }
        if format != .unrecognized {
            fields[BundledRelationKey.relationFormat.rawValue] = format.asMiddleware.rawValue.protobufValue
        }
        if objectTypes.isNotEmpty {
            fields[BundledRelationKey.relationFormatObjectTypes.rawValue] = objectTypes.protobufValue
        }
        return fields
    }
}


public extension RelationDetails {
    var isMultiSelect: Bool {
        return maxCount == 0
    }
}
