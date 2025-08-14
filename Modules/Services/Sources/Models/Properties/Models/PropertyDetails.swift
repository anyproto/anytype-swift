import Foundation
import SwiftProtobuf

public struct PropertyDetails: Hashable, Sendable {

    public let id: String
    public let key: String
    public let name: String
    public let format: PropertyFormat
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
        format: PropertyFormat,
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

extension PropertyDetails: DetailsModel {
    
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
    
    public static var subscriptionKeys: [BundledPropertyKey] {
        return [
            BundledPropertyKey.id,
            BundledPropertyKey.relationKey,
            BundledPropertyKey.name,
            BundledPropertyKey.relationFormat,
            BundledPropertyKey.relationReadonlyValue,
            BundledPropertyKey.relationFormatObjectTypes,
            BundledPropertyKey.isHidden,
            BundledPropertyKey.isReadonly,
            BundledPropertyKey.relationMaxCount,
            BundledPropertyKey.sourceObject,
            BundledPropertyKey.spaceId,
            BundledPropertyKey.lastUsedDate
        ]
    }
    
    public var asMiddleware: Google_Protobuf_Struct {
        return Google_Protobuf_Struct(fields: fields)
    }
    
    public var fields: [String: Google_Protobuf_Value] {
        var fields = [String: Google_Protobuf_Value]()
        if name.isNotEmpty {
            fields[BundledPropertyKey.name.rawValue] = name.protobufValue
        }
        if format != .unrecognized {
            fields[BundledPropertyKey.relationFormat.rawValue] = format.asMiddleware.rawValue.protobufValue
        }
        if objectTypes.isNotEmpty {
            fields[BundledPropertyKey.relationFormatObjectTypes.rawValue] = objectTypes.protobufValue
        }
        return fields
    }
}


public extension PropertyDetails {
    var isMultiSelect: Bool {
        return maxCount == 0
    }
}
