import ProtobufMessages
import AnytypeCore


public enum MiddlewareObjectRestrictionsConverter {

    public static func convertObjectRestrictions(middlewareRestrictions: Anytype_Model_Restrictions) -> ObjectRestrictions {
        let objectRestrictions: [ObjectRestriction] = middlewareRestrictions.object.compactMap { middleRestriction in
            let restriction = ObjectRestriction(rawValue: middleRestriction.rawValue)
            anytypeAssert(restriction.isNotNil, "Unsupported restriction \(middleRestriction.rawValue)")
            return restriction
        }

        let dataViewRestrictions = middlewareRestrictions.dataview.reduce(
            [String: [DataViewRestriction]]()
        ) { partialResult, blockDataViewRestrictions in
            var partialResult = partialResult

            partialResult[blockDataViewRestrictions.blockID] = blockDataViewRestrictions.restrictions.compactMap { dataViewRestriction in
                DataViewRestriction(rawValue: dataViewRestriction.rawValue)
            }
            return partialResult
        }

        return .init(objectRestriction: objectRestrictions, dataViewRestriction: dataViewRestrictions)
    }
}
