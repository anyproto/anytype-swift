//
//  CompletionAuthViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import SwiftUI

class CompletionAuthViewModel: ObservableObject, CompletionAuthViewDelegate {
    var coordinator: CompletionAuthViewCoordinator
    
    init(coordinator: CompletionAuthViewCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - CompletionAuthViewDelegate
    func showDashboardDidTap() {
        coordinator.routeToOldHomeView()
    }
}
