//
//  MiddlewareObjectRestrictionsConverter.swift
//  BlocksModels
//
//  Created by Denis Batvinkin on 21.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import ProtobufMessages


public enum MiddlewareObjectRestrictionsConverter {

    public static func convertObjectRestrictions(middlewareResctrictions: Anytype_Model_Restrictions) -> ObjectRestrictions {
        let objectRestrictions = middlewareResctrictions.object.compactMap { objectRestrictions in
            ObjectRestrictions.ObjectRestriction(rawValue: objectRestrictions.rawValue)
        }

        let dataViewRestrictions = middlewareResctrictions.dataview.reduce(
            [BlockId: [ObjectRestrictions.DataViewRestriction]]()
        ) { partialResult, blockDataViewRestrictions in
            var partialResult = partialResult

            partialResult[blockDataViewRestrictions.blockID] = blockDataViewRestrictions.restrictions.compactMap { dataViewRestriction in
                ObjectRestrictions.DataViewRestriction(rawValue: dataViewRestriction.rawValue)
            }
            return partialResult
        }

        return .init(objectRestriction: objectRestrictions, dataViewRestriction: dataViewRestrictions)
    }
}
