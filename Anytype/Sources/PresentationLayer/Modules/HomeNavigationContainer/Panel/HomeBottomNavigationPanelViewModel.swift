import Foundation
import Services
import Combine
import UIKit
import AnytypeCore
import Services

@MainActor
final class HomeBottomNavigationPanelViewModel: ObservableObject {
    
    // MARK: - Private properties
    private let info: AccountInfo
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private var processSubscriptionService: ProcessSubscriptionServiceProtocol
    private let accountParticipantStorage: AccountParticipantsStorageProtocol
        
    private weak var output: HomeBottomNavigationPanelModuleOutput?
    private let subId = "HomeBottomNavigationProfile-\(UUID().uuidString)"
    
    private var activeProcess: Process?
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var profileIcon: Icon?
    @Published var progress: Double? = nil
    @Published var canCreateObject: Bool = false
    
    init(
        info: AccountInfo,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        processSubscriptionService: ProcessSubscriptionServiceProtocol,
        accountParticipantStorage: AccountParticipantsStorageProtocol,
        output: HomeBottomNavigationPanelModuleOutput?
    ) {
        self.info = info
        self.subscriptionService = subscriptionService
        self.defaultObjectService = defaultObjectService
        self.processSubscriptionService = processSubscriptionService
        self.accountParticipantStorage = accountParticipantStorage
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
    
    func onAppear() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            canCreateObject = canEdit
        }
    }
        
    // MARK: - Private
    
    private func setupDataSubscription() {
        Task {
            await subscriptionService.startSubscription(
                subId: subId,
                objectId: info.profileObjectID
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
            guard let details = try? await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: info.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .navigation)
            
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
