//
//  ObjectTypesService.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import AnytypeCore
import BlocksModels

public class ObjectTypesService: ObjectTypesServiceProtocol {
    
    public init() {}
    
    public func obtainObjectTypes() -> Set<ObjectType> {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeUrls: [ObjectTypeUrl.bundled(.objectType).rawValue])
        ]
        
        let result = makeRequest(filters: filters, sorts: [sort], fullText: "", limit: 0)
        
        let items = result?.map { ObjectType(details: $0) } ?? []
        
        return Set(items)
//        let result = Anytype_Rpc.ObjectType.List.Service.invoke()
//        switch result {
//        case .success(let response):
//            let error = response.error
//            switch error.code {
//            case .null:
//                let objectTypes = response.objectTypes
//
//                guard objectTypes.isNotEmpty else {
//                    anytypeAssertionFailure("ObjectTypeList response is empty", domain: .objectTypeProvider)
//                    return []
//                }
//
//                return Set(objectTypes.map { ObjectType(model: $0) })
//            case .unknownError, .badInput, .UNRECOGNIZED:
//                anytypeAssertionFailure(error.description_p, domain: .objectTypeProvider)
//                return []
//            }
//        case .failure(let error):
//            anytypeAssertionFailure(error.localizedDescription, domain: .objectTypeProvider)
//            return []
//        }
    }
    
    private func makeRequest(
        filters: [DataviewFilter],
        sorts: [DataviewSort],
        fullText: String,
        limit: Int32 = 100
    ) -> [ObjectDetails]? {
        guard let response = Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: 0,
            limit: limit,
            objectTypeFilter: [],
            keys: []
        ).getValue(domain: .searchService) else { return nil }
            
        let details: [ObjectDetails] = response.records.compactMap { search in
            let idValue = search.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
            
            guard let id = idString else { return nil }
            
            return ObjectDetails(id: id, values: search.fields)
        }
            
        return details
    }
    
}
