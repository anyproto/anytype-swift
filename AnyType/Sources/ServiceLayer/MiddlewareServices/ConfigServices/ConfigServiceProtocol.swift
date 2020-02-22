//
//  ConfigServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Lib
import Combine

/// Service that handles middleware config
protocol MiddleConfigServiceProtocol {
    typealias MiddlwareConfig = MiddlewareModels.MiddlwareConfig
    
    /// Obtain middleware config
    /// - Parameter completion: called on completion
    func obtainConfig() -> AnyPublisher<MiddlwareConfig, Error>
}
