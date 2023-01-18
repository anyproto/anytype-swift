import Foundation
import SwiftProtobuf

public struct RelationDetails: Hashable {

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
        isDeleted: Bool
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
    }
}

public extension RelationDetails {
    
    init(objectDetails: ObjectDetails) {
        self.id = objectDetails.id
        self.key = objectDetails.relationKey
        self.name = objectDetails.name
        self.format = objectDetails.relationFormatValue
        self.isHidden = objectDetails.isHidden
        self.isReadOnly = objectDetails.isReadonly
        self.isReadOnlyValue = objectDetails.relationReadonlyValue
        self.objectTypes = objectDetails.relationFormatObjectTypes
        self.maxCount = objectDetails.relationMaxCount ?? 0
        self.sourceObject = objectDetails.sourceObject
        self.isDeleted = objectDetails.isDeleted
    }
    
    var asCreateMiddleware: Google_Protobuf_Struct {
        var fields = [String: Google_Protobuf_Value]()
        if name.isNotEmpty {
            fields[BundledRelationKey.name.rawValue] = name.protobufValue
        }
        if format != .unrecognized {
            fields[BundledRelationKey.relationFormat.rawValue] = format.rawValue.protobufValue
        }
        if objectTypes.isNotEmpty {
            fields[BundledRelationKey.relationFormatObjectTypes.rawValue] = objectTypes.protobufValue
        }
        
        return Google_Protobuf_Struct(fields: fields)
    }
}


public extension RelationDetails {
    var isMultiSelect: Bool {
        return maxCount == 0
    }
}
