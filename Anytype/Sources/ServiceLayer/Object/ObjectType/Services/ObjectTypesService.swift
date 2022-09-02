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
    
    private let searchCommonService: SearchCommonServiceProtocol
    
    init(searchCommonService: SearchCommonServiceProtocol) {
        self.searchCommonService = searchCommonService
    }
    
    // MARK: - ObjectTypesServiceProtocol
    
    public func obtainObjectTypes() -> Set<ObjectType> {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeUrls: [ObjectTypeUrl.bundled(.objectType).rawValue])
        ]
        
        let result = searchCommonService.search(filters: filters, sorts: [sort], limit: 0)
        
        let items = result?.map { ObjectType(details: $0) } ?? []
        
        return Set(items)
    }
}
