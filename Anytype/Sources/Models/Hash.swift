//
//  Hash.swift
//  Anytype
//
//  Created by Konstantin Mordan on 28.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

struct Hash {
    
    let value: String
    
    // MARK: - Initializer
    
    init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else {
            return nil
        }
        
        self.value = value
    }
}
