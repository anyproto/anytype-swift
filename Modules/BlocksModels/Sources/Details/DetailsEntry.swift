//
//  DetailsEntry.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

public struct DetailsEntry {
    
    public let kind: DetailsKind
    public let value: String
    
    public var id: String {
        kind.rawValue
    }
    
    public init(kind: DetailsKind, value: String) {
        self.kind = kind
        self.value = value
    }
       
}

extension DetailsEntry: Hashable {}
