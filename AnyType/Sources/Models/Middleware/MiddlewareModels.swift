//
//  MiddlewareModels.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

enum MiddlewareModels{}

/// Middleware configuration
extension MiddlewareModels {
    
    struct Configuration: Equatable {
        let homeBlockID: String
        let archiveBlockID: String
        let gatewayURL: String
    }
    struct Version {
        let version: String
    }
}
