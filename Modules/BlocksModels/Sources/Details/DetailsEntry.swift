//
//  DetailsEntry.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

public struct DetailsEntry<V: Hashable> {
    
    public let kind: DetailsKind
    public let value: V
    
    public var id: String {
        kind.rawValue
    }
    
    public init(kind: DetailsKind, value: V) {
        self.kind = kind
        self.value = value
    }
       
}

extension DetailsEntry: Hashable {}
