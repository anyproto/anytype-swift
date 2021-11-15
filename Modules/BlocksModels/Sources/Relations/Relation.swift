import Foundation
import ProtobufMessages

public struct Relation: Hashable {
    
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
    
    public init(
        key: String,
        name: String,
        format: Format,
        isHidden: Bool,
        isReadOnly: Bool,
        isMulti: Bool,
        selections: [Option],
        objectTypes: [String]
    ) {
        self.key = key
        self.name = name
        self.format = format
        self.isHidden = isHidden
        self.isReadOnly = isReadOnly
        self.isMulti = isMulti
        self.selections = selections
        self.objectTypes = objectTypes
    }
    
}

extension Relation: Identifiable {

    public var id: String {
        return key
    }
    
}

public extension Relation {
    
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
    }
    
}
