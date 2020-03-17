//
//  ConfigurationServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

/// Service that handles middleware config
protocol ConfigurationServiceProtocol {
    typealias MiddlewareConfiguration = MiddlewareModels.MiddlwareConfiguration
    
    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error>
}
