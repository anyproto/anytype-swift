//
//  CompletionAuthViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import SwiftUI

class CompletionAuthViewModel: ObservableObject {
    var coordinator: CompletionAuthViewCoordinator
    
    init(coordinator: CompletionAuthViewCoordinator) {
        self.coordinator = coordinator
    }
}

// MARK: - CompletionAuthViewDelegate
extension CompletionAuthViewModel: CompletionAuthViewDelegate {
    func showDashboardDidTap() {
        coordinator.routeToHomeView()
    }
}
