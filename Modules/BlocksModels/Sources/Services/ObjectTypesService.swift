//
//  ObjectTypesService.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import AnytypeCore

public class ObjectTypesService: ObjectTypesServiceProtocol {
    
    public init() {}
    
    public func obtainObjectTypes() -> Set<ObjectType> {
        let result = Anytype_Rpc.ObjectType.List.Service.invoke()
        switch result {
        case .success(let response):
            let error = response.error
            switch error.code {
            case .null:
                let objectTypes = response.objectTypes
                
                guard objectTypes.isNotEmpty else {
                    anytypeAssertionFailure("ObjectTypeList response is empty", domain: .objectTypeProvider)
                    return []
                }
                
                return Set(objectTypes.map { ObjectType(model: $0) })
            case .unknownError, .badInput, .UNRECOGNIZED:
                anytypeAssertionFailure(error.description_p, domain: .objectTypeProvider)
                return []
            }
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: .objectTypeProvider)
            return []
        }
    }
    
}
