//
//  ProfileViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI
import os
import BlocksModels

private extension Logging.Categories {
    static let storiesProfileViewModel: Self = "Stories.Profile.ViewModel"
}

final class ProfileViewModel: ObservableObject {
    /// Typealiases
    typealias DetailsAccessor = InformationAccessor
    
    /// Variables / Services
    private var profileService: ProfileServiceProtocol
    private var authService: AuthServiceProtocol
    
    /// Variables / Error
    @Published var error: String = "" {
        didSet {
            self.isShowingError = true
        }
    }
    @Published var isShowingError: Bool = false
    
    var visibleAccountName: String {
        guard let name = self.accountName, !name.isEmpty else {
            return "Anytype User"
        }
        return name
    }
    
    var visibleSelectedColor: UIColor {
        self.selectedColor ?? .clear
    }
    
    /// User Model
    @Published var accountName: String?
    @Published var accountAvatar: UIImage?
    @Published var selectedColor: UIColor?
    
    /// Device Model
    @Published var updates: Bool = UserDefaultsConfig.notificationUpdates {
        didSet {
            UserDefaultsConfig.notificationUpdates = updates
        }
    }
    @Published var newInvites: Bool = UserDefaultsConfig.notificationNewInvites {
        didSet {
            UserDefaultsConfig.notificationNewInvites = newInvites
        }
    }
    @Published var newComments: Bool = UserDefaultsConfig.notificationNewComments {
        didSet {
            UserDefaultsConfig.notificationNewComments = newComments
        }
    }
    @Published var newDevice: Bool = UserDefaultsConfig.notificationNewDevice {
        didSet {
            UserDefaultsConfig.notificationNewDevice = newDevice
        }
    }
    
    // MARK: - Model
    private var obtainUserInformationSubscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    
    private var documentViewModel: BlocksViews.DocumentViewModel = .init()
    
    // MARK: - Initialization
    init(profileService: ProfileServiceProtocol, authService: AuthServiceProtocol) {
        self.profileService = profileService
        self.authService = authService
        self.setupSubscriptions()
    }

    // MARK: - Obtain Account Info
    func obtainAccountInfo() {
        self.obtainUserInformationSubscription = self.profileService.obtainUserInformation().sink(receiveCompletion: { (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                let logger = Logging.createLogger(category: .storiesProfileViewModel)
                os_log(.debug, log: logger, "obtainAccountInfo. Error has occured. %@", String(describing: error))
            }
        }) { [weak self] (value) in
            self?.handleOpenBlock(value)
        }
    }

    // MARK: - Setup Subscriptions
    func setupSubscriptions() {
        let publisher = self.documentViewModel.defaultDetailsAccessorPublisher()
        
        publisher.map(\.title).map({$0?.value}).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.accountName = value
        }.store(in: &self.subscriptions)
        
        publisher.map(\.iconColor).map({$0?.value}).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.selectedColor = .init(hexString: value)
        }.store(in: &self.subscriptions)
        
        publisher.map(\.iconImage).map({$0?.value}).safelyUnwrapOptionals().flatMap({value in CoreLayer.Network.Image.URLResolver.init().transform(imageId: value).ignoreFailure()})
            .safelyUnwrapOptionals().flatMap({value in CoreLayer.Network.Image.Loader.init(value).imagePublisher}).receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.accountAvatar = value
        }.store(in: &self.subscriptions)
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            let view = MainAuthView(viewModel: MainAuthViewModel())
            applicationCoordinator?.startNewRootView(content: view)
        }
    }

    // MARK: - Handle Open Action
    func handleOpenBlock(_ value: ServiceSuccess) {
        self.documentViewModel.open(value)
    }
}
