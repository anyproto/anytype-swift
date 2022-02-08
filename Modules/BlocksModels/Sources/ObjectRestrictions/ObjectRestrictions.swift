public struct ObjectRestrictions {

    public enum ObjectRestriction: Int {
        case none
        case delete
        case relations
        case blocks
        case details
        case typechange
        case layoutchange
        case templat
    }

    public enum DataViewRestriction: Int {
        case DVNone
        case DVRelation
        case DVCreateObject
        case DVViews
    }

    public let objectRestriction: [ObjectRestriction]
    public let dataViewRestriction: [BlockId: [DataViewRestriction]]

    public init() {
        objectRestriction = []
        dataViewRestriction = [:]
    }

    public init(objectRestriction: [ObjectRestriction], dataViewRestriction: [BlockId: [DataViewRestriction]]) {
        self.objectRestriction = objectRestriction
        self.dataViewRestriction = dataViewRestriction
    }
}
