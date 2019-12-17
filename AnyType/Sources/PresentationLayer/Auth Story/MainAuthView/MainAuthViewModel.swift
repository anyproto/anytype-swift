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
        print("repoPath: \(localRepoService.middlewareRepoPath)")
    }
    
    func singUp() {
        try? self.storeService.removeSeed(for: nil, keyChainPassword: nil)
        
        authService.createWallet(in: localRepoService.middlewareRepoPath) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error.localizedDescription
            case .success(let seed):
                // TODO: handel error
                // TODO: here is we need true password
                try? self?.storeService.saveSeedForAccount(name: nil, seed: seed, keyChainPassword: nil)
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
