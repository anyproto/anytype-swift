//
//  FieldsConvertibleProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 27.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

public protocol FieldsConvertibleProtocol {
    func asMiddleware() -> BlockFields
}
