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
    func subscribeDashboardEvents() -> AnyPublisher<Never, Error>
    
    /// Obtain document and its blocks
    func obtainDashboardBlocks() -> AnyPublisher<Anytype_Event.Block.Show, Never>
    
    /// Create pages
    func createPage(contextId: String) -> AnyPublisher<Never, Error>
}
