import ProtobufMessages

public typealias ObjectRestriction = Anytype_Model_Restrictions.ObjectRestriction

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
