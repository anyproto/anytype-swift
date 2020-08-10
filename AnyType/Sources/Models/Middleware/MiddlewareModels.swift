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
/// TODO: Move to BlockModels module.
extension MiddlewareModels {
    struct Configuration: Hashable {
        let homeBlockID: String
        let archiveBlockID: String
        let profileBlockId: String
        let gatewayURL: String
    }
    struct Version: Hashable {
        let version: String
    }
}
