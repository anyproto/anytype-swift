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
    private var authService: AuthServiceProtocol = AnytypeAuthService()
    private let storeService: StoreServiceProtocol = KeychainStoreService()
    
    @Published var error: String = "" {
        didSet {
            if !error.isEmpty {
                isShowingError = true
            }
        }
    }
    @Published var isShowingError: Bool = false
    @Published var shouldShowCreateProfileView: Bool = false
    
    func singUp() {
        let path = getDocumentsDirectory().appendingPathComponent("textile-go").path
        authService.createWallet(in: path) { [weak self] result in
            
            switch result {
            case .failure(let error):
                self?.error = error.localizedDescription
            case .success(let seed):
                // TODO: handel error
                // TODO: here is we need true password
                try? self?.storeService.saveSeedForAccount(name: "defaultSeed", seed: seed, keyChainPassword: "temppass")
                self?.shouldShowCreateProfileView = true
            }
        }
    }
    
    // MARK: - Coordinator
    
    func showCreateProfileView(showCreateProfileView: Binding<Bool>) -> some View {
        return CreateNewProfileView(showCreateProfileView: showCreateProfileView)
    }
    
    func showLoginView() -> some View {
        return LoginView()
    }
}
