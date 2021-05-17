//
//  StringExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

extension String {
    
    var isSingleEmoji: Bool {
        count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        !isEmpty && !contains { !$0.isEmoji }
    }
    
}
