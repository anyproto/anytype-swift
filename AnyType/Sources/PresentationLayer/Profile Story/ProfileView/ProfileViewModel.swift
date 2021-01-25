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
    typealias RootModel = TopLevelContainerModelProtocol
    typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
    
    typealias DetailsAccessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor
    
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
    
    private let eventProcessor: EditorModule.Document.ViewController.ViewModel.EventProcessor = .init()
    private var rootModel: RootModel? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    private let transformer: Transformer = .defaultValue
    var pageDetailsViewModel: EditorModule.Document.ViewController.ViewModel.PageDetailsViewModel = .init()
    
    // MARK: - Lifecycle
    
    init(profileService: ProfileServiceProtocol, authService: AuthServiceProtocol) {
        self.profileService = profileService
        self.authService = authService
        self.setupSubscriptions()
    }
    
    // MARK: - Public methods
    
    func obtainAccountInfo() {
        self.obtainUserInformationSubscription = self.profileService.obtainUserInformation().sink(receiveCompletion: { (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                let logger = Logging.createLogger(category: .storiesProfileViewModel)
                os_log(.debug, log: logger, "TextBlocksViews setAlignment error has occured. %@", String(describing: error))
            }
        }) { [weak self] (value) in
            // Next, we should parse model.
            // And only after that we should do other stuff.
            self?.handleOpenBlock(value)
        }
//        accountName = profileService.name ?? ""
//        if accountName.isEmpty {
//            accountName = theAccountName
//        }
//        if let avatarURL = profileService.avatar.flatMap(URL.init(string:)) {
//            self.accountAvatar = ImageLoaderCache.shared.loaderFor(path: avatarURL).image
//        }
    }
        
    func setupSubscriptions() {
        let publisher = self.pageDetailsViewModel.$currentDetails.safelyUnwrapOptionals().map(DetailsAccessor.init)
        
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
    
    func logout() {
        self.authService.logout() {
            let view = MainAuthView(viewModel: MainAuthViewModel())
            applicationCoordinator?.startNewRootView(content: view)
        }
    }
}

// MARK: React on root model
private extension ProfileViewModel {
    func handleNewRootModel(_ model: RootModel?) {
        if let model = self.rootModel {
            // We don't need to process events.
            // Instead, we just listen for them.
//            self.eventProcessor.didProcessEventsPublisher.sink(receiveValue: { [weak self] (value) in
////                switch value {
////                case .update(.empty): return
////                default: break
////                }
////
////                self?.syncBuilders()
//            }).store(in: &self.subscriptions)
            _ = self.eventProcessor.configured(model)
        }
        // No need to flatten blocks or sync builders.
        // We only listen to details.
//        _ = self.flattener.configured(self.rootModel)
//        self.syncBuilders()
        self.configurePageDetails(for: self.rootModel)
    }
}

// MARK: - Handle Open Action
private extension ProfileViewModel {
    func handleOpenBlock(_ value: ServiceLayerModule.Success) {
        let blocks = self.eventProcessor.handleBlockShow(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        guard let event = blocks.first else { return }
        
        /// Now transform and create new container.
        ///
        /// And then, sync builders...

        let rootId = value.contextID
        
        let blocksContainer = self.transformer.transform(event.blocks, rootId: rootId)
        let parsedDetails = event.details.map(TopLevel.Builder.detailsBuilder.build(information:))
        let detailsContainer = TopLevel.Builder.detailsBuilder.build(list: parsedDetails)
        
        /// Add details models to process.
        self.rootModel = TopLevel.Builder.build(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsContainer)
    }
}

// MARK: - Configure Page Details
private extension ProfileViewModel {
    func configurePageDetails(for rootModel: RootModel?) {
        guard let model = rootModel else { return }
        guard let rootId = model.rootId, let ourModel = model.detailsContainer.choose(by: rootId) else { return }
        let detailsPublisher = ourModel.didChangeInformationPublisher()
        self.pageDetailsViewModel.configured(publisher: detailsPublisher)
    }
}
