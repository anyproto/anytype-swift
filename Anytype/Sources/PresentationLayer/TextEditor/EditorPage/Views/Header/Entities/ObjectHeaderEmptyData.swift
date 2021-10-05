//
//  ObjectHeaderEmptyData.swift
//  Anytype
//
//  Created by Konstantin Mordan on 24.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct ObjectHeaderEmptyData: Hashable {
    let onTap: () -> Void
}

extension ObjectHeaderEmptyData {
    
    func hash(into hasher: inout Hasher) {}
    
    static func == (lhs: ObjectHeaderEmptyData, rhs: ObjectHeaderEmptyData) -> Bool {
        return true
    }
    
}
