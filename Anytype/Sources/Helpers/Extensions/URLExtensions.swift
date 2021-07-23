//
//  URLExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

extension URL {
    
    var containsHttpProtocol: Bool {
        guard let scheme = scheme else { return false }
        
        return scheme.isEqual("https") || scheme.isEqual("http")
    }
    
}
