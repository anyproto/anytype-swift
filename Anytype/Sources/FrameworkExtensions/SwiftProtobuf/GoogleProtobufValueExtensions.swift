//
//  GoogleProtobufValueExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftProtobuf

extension Google_Protobuf_Value {
    
    var safeIntValue: Int? {
        guard
            case let .numberValue(number) = kind,
            !number.isNaN
        else {
            return nil
        }
        
        return Int(number)
    }
    
}
