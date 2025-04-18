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
    
    func urlByAddingHttpsIfSchemeIsEmpty() -> URL {
        guard scheme.isNil || scheme == "" else {
            return self
        }
        return urlBySettingScheme(Constants.https)
    }
    
    private func urlBySettingScheme(_ scheme: String) -> URL {
        return URL(string: "\(scheme)://\(absoluteString)") ?? self
    }
    
    enum Constants {
        static let http = "http"
        static let https = "https"
    }
    
}
