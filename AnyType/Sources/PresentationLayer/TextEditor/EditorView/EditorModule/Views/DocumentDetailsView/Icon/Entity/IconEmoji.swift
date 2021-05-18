//
//  IconEmoji.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

struct IconEmoji {
    
    let value: String
    
    // MARK: - Initializer
    
    init?(_ value: String?) {
        guard let value = value, value.isSingleEmoji else { return nil }
        
        self.value = value
    }
    
}
