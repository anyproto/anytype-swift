public enum ObjectRestriction: Int {
    case none
    case delete
    case relations
    case blocks
    case details
    case typechange
    case layoutchange
    case template
    case duplicate
}

public enum DataViewRestriction: Int {
    case DVNone
    case DVRelation
    case DVCreateObject
    case DVViews
}

public struct ObjectRestrictions {
    public let objectRestriction: [ObjectRestriction]
    public let dataViewRestriction: [String: [DataViewRestriction]]

    public init() {
        objectRestriction = []
        dataViewRestriction = [:]
    }

    public init(objectRestriction: [ObjectRestriction], dataViewRestriction: [String: [DataViewRestriction]]) {
        self.objectRestriction = objectRestriction
        self.dataViewRestriction = dataViewRestriction
    }
}
