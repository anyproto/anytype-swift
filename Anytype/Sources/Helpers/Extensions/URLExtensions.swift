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
        
        return scheme.isEqual(Constants.https) || scheme.isEqual(Constants.http)
    }
    
    func urlByAddingHttpIfSchemeIsEmpty() -> URL {
        guard scheme.isNil || scheme == "" else {
            return self
        }
        return urlBySettingScheme(Constants.http)
    }
    
    private func urlBySettingScheme(_ scheme: String) -> URL {
        var components = URLComponents(string: absoluteString)
        components?.scheme = scheme
        return components?.url ?? self
    }
    
    enum Constants {
        static let http = "http"
        static let https = "https"
    }
    
}
