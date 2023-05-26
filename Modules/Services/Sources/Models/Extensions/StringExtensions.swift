//
//  StringExtensions.swift
//  Services
//
//  Created by Konstantin Mordan on 29.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import AnytypeCore

extension String {
    
    var isValidId: Bool {
        self.trimmed.isNotEmpty
    }
    
}
