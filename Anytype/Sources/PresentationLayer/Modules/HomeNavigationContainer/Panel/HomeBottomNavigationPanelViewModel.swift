import Foundation
import Services
import Combine
import UIKit
import AnytypeCore
import Services

@MainActor
final class HomeBottomNavigationPanelViewModel: ObservableObject {
    
    // MARK: - Private properties
    
    private let activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private var processSubscriptionService: ProcessSubscriptionServiceProtocol
    private weak var output: HomeBottomNavigationPanelModuleOutput?
    private let subId = "HomeBottomNavigationProfile-\(UUID().uuidString)"
    
    private var activeProcess: Process?
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var isEditState: Bool = false
    @Published var profileIcon: Icon?
    @Published var progress: Double? = nil
    
    init(
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        processSubscriptionService: ProcessSubscriptionServiceProtocol,
        output: HomeBottomNavigationPanelModuleOutput?
    ) {
        self.activeWorkpaceStorage = activeWorkpaceStorage
        self.subscriptionService = subscriptionService
        self.defaultObjectService = defaultObjectService
        self.processSubscriptionService = processSubscriptionService
        self.output = output
        setupDataSubscription()
    }
    
    func onTapForward() {
        output?.onForwardSelected()
    }
    
    func onTapBackward() {
        output?.onBackwardSelected()
    }
    
    func onTapNewObject() {
        handleCreateObject()
    }
    
    func onTapSearch() {
        output?.onSearchSelected()
    }
    
    func onTapHome() {
        output?.onHomeSelected()
    }
    
    func onTapProfile() {
        output?.onProfileSelected()
    }
    
    func onPlusButtonLongtap() {
        output?.onPickTypeForNewObjectSelected()
    }
        
    // MARK: - Private
    
    private func setupDataSubscription() {
        Task {
            await subscriptionService.startSubscription(
                subId: subId,
                objectId: activeWorkpaceStorage.workspaceInfo.profileObjectID
            ) { [weak self] details in
                self?.handleProfileDetails(details: details)
            }
            
            await processSubscriptionService.addHandler { [weak self] events in
                self?.handleProcesses(events: events)
            }.store(in: &subscriptions)
        }
    }
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileIcon = details.objectIconImage
    }
    
    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: activeWorkpaceStorage.workspaceInfo.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation)
            
            output?.onCreateObjectSelected(screenData: details.editorScreenData())
        }
    }
    
    private func handleProcesses(events: [ProcessEvent]) {
        for event in events {
            switch event {
            case .new(let process):
                guard activeProcess.isNil else { return }
                activeProcess = process
                progress = Double(process.progress.done) / Double(process.progress.total)
            case .update(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = process
                progress = Double(process.progress.done) / Double(process.progress.total)
            case .done(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = nil
                progress = Double(process.progress.done) / Double(process.progress.total)
                Task {
                    try await Task.sleep(seconds: 2)
                    // If other process not executing
                    if activeProcess.isNil {
                        progress = nil
                    }
                }
            }
        }
    }
}
