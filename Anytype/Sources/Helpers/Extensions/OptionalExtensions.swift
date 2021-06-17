//
//  OptionalExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

public extension Optional {

    // This property should be used instead of comparision with `nil` literal to decrease compilation time.
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }

}

