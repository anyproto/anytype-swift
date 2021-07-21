//
//  CompletionAuthViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import SwiftUI
import Amplitude

final class CompletionAuthViewModel: ObservableObject, CompletionAuthViewDelegate {
    var coordinator: CompletionAuthViewCoordinator
    private let loginStateService: LoginStateService
    
    init(coordinator: CompletionAuthViewCoordinator,
         loginStateService: LoginStateService) {
        self.coordinator = coordinator
        self.loginStateService = loginStateService
    }

    // MARK: - CompletionAuthViewDelegate
    func showDashboardDidTap() {
        loginStateService.setupStateAfterLoginOrAuth()
        coordinator.routeToHomeView()
    }

    // MARK: - View output
    func viewLoaded() {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.accountCreate)
    }
}
