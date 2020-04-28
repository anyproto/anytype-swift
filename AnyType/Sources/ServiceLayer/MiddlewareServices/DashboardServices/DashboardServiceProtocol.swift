//
//  DashboardServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

/// Dashboard service
protocol DashboardServiceProtocol {
    /// Subscribe to dashboard events
    func subscribeDashboardEvents() -> AnyPublisher<[Anytype_Event.Message], Error>
    
    /// Create pages
    func createPage(contextId: String) -> AnyPublisher<[Anytype_Event.Message], Error>
}
