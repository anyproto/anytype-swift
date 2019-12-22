//
//  MainAuthViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


class MainAuthViewModel: ObservableObject {
    @Environment(\.localRepoService) private var localRepoService
    
    private var authService: AuthServiceProtocol = AuthService()
    private let storeService: SecureStoreServiceProtocol = KeychainStoreService()
    
    @Published var error: String = "" {
        didSet {
            if !error.isEmpty {
                isShowingError = true
            }
        }
    }
    @Published var isShowingError: Bool = false
    @Published var shouldShowCreateProfileView: Bool = false
    
    init() {
        // TODO: Move to auth service, and call this from fabric or coordiantor
        try? FileManager.default.removeItem(atPath: localRepoService.middlewareRepoPath)
        print("repoPath: \(localRepoService.middlewareRepoPath)")
        
    }
    
    func singUp() {
        authService.createWallet(in: localRepoService.middlewareRepoPath) { [weak self] result in
            switch result {
            case .failure(let error):
                // TODO: handel error
                self?.error = error.localizedDescription
            case .success:
                self?.shouldShowCreateProfileView = true
            }
        }
    }
    
    // MARK: - Coordinator
    
    func showCreateProfileView() -> some View {
        return CreateNewProfileView(viewModel: CreateNewProfileViewModel())
    }
    
    func showLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
