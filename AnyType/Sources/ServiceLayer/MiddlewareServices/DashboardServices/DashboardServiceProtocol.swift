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
    func openDashboard() -> AnyPublisher<ServiceSuccess, Error>
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceSuccess, Error>    
}
