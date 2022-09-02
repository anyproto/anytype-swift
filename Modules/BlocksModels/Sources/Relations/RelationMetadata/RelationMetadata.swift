import Foundation
import ProtobufMessages
import SwiftProtobuf

public struct RelationInfo: Hashable {
    public let id: String
    public let key: String
    public let name: String
    public let format: RelationMetadata.Format
    public let isHidden: Bool
    public let isReadOnly: Bool

    public init(objectDetails: ObjectDetails) {
        self.id = objectDetails.id
        self.key = objectDetails.values["relationKey"]?.stringValue ?? ""
        self.name = objectDetails.name
        self.format = objectDetails.values["relationFormat"]?.safeIntValue.map { RelationMetadata.Format(rawValue: $0) } ?? .unrecognized
        self.isHidden = objectDetails.isHidden
        self.isReadOnly = objectDetails.isReadonly
    }
}

public struct RelationMetadata: Hashable {
    
    public let key: String
    public let name: String
    public let format: Format
    public let isHidden: Bool
    public let isReadOnly: Bool
    public let isMulti: Bool
    // list of values for multiple relations. ex.: tags
    public let selections: [Option]
    // list of types used by relation. ex.: type of file
    public let objectTypes: [String]
    public let scope: Scope
    
    public let isBundled: Bool
    
    public init(
        key: String,
        name: String,
        format: Format,
        isHidden: Bool,
        isReadOnly: Bool,
        isMulti: Bool,
        selections: [Option],
        objectTypes: [String],
        scope: Scope,
        isBundled: Bool
    ) {
        self.key = key
        self.name = name
        self.format = format
        self.isHidden = isHidden
        self.isReadOnly = isReadOnly
        self.isMulti = isMulti
        self.selections = selections
        self.objectTypes = objectTypes
        self.scope = scope
        self.isBundled = isBundled
    }
}

extension RelationMetadata: Identifiable {
    
    public var id: String {
        return key
    }
}

public extension RelationMetadata {
    
    init(middlewareRelation: Anytype_Model_Relation) {
        self.key = middlewareRelation.key
        self.name = middlewareRelation.name
        self.format = Format(rawValue: middlewareRelation.format.rawValue)
        self.isHidden = middlewareRelation.hidden
        self.isReadOnly = middlewareRelation.readOnly
        self.isMulti = middlewareRelation.multi
        self.selections = middlewareRelation.selectDict.map {
            Option(middlewareOption: $0)
        }
        self.objectTypes = middlewareRelation.objectTypes
        self.scope = Scope(rawValue: middlewareRelation.scope.rawValue)
        self.isBundled = BundledRelationKey(rawValue: middlewareRelation.key).isNotNil
    }

    var asMiddleware: Anytype_Model_Relation {
        let scope = Anytype_Model_Relation.Scope(rawValue: scope.rawValue) ?? .object
        let format = Anytype_Model_RelationFormat(rawValue: format.rawValue) ?? .longtext

        return Anytype_Model_Relation(
            key: key,
            format: format,
            name: name,
            defaultValue: SwiftProtobuf.Google_Protobuf_Value(),
            dataSource: .local,
            hidden: isHidden,
            readOnly: isReadOnly,
            readOnlyRelation: false,
            multi: isMulti,
            objectTypes: objectTypes,
            selectDict: selections.map {
                $0.asMiddleware
            },
            maxCount: 0,
            description_p: "",
            scope: scope,
            creator: ""
        )
    }
}

public extension Anytype_Model_Relation {
    var asModel: RelationMetadata {
        RelationMetadata(middlewareRelation: self)
    }
}
