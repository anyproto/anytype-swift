//
//  DetailsEntry.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

public struct DetailsEntry<V: Hashable> {
    
    public let value: V
    
    public init(value: V) {
        self.value = value
    }
       
}

extension DetailsEntry: Hashable {}
