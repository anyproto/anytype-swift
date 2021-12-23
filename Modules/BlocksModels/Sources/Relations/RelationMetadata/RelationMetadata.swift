import Foundation
import ProtobufMessages
import SwiftProtobuf

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
    
    public init(
        key: String,
        name: String,
        format: Format,
        isHidden: Bool,
        isReadOnly: Bool,
        isMulti: Bool,
        selections: [Option],
        objectTypes: [String],
        scope: Scope
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
    }

    var middlewareModel: Anytype_Model_Relation {
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
                $0.middlewareModel
            },
            maxCount: 0,
            description_p: "",
            scope: scope,
            creator: "")
    }
}
