import Foundation
import ProtobufMessages
import AnytypeCore
import Combine
import UIKit
import Services

@MainActor
final class SettingsAccountViewModel: ObservableObject {
 
    private enum Constants {
        static let subId = "SettingsAccount"
    }
    
    // MARK: - DI
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: SettingsAccountModuleOutput?
    
    // MARK: - State
    
    @Published var profileIcon: ObjectIconImage?
    @Published var profileName: String = ""
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded: Bool = false
    
    init(
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: SettingsAccountModuleOutput?
    ) {
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.objectActionsService = objectActionsService
        self.output = output
        
        setupSubscription()
    }
    
    func onRecoveryPhraseTap() {
        output?.onRecoveryPhraseSelected()
    }
    
    func onDeleteAccountTap() {
        output?.onDeleteAccountSelected()
    }
    
    func onLogOutTap() {
        output?.onLogoutSelected()
    }
    
    func onChangeIconTap() {
        output?.onChangeIconSelected(objectId: accountManager.account.info.profileObjectID)
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.updateProfile(details: details)
        }
    }
    
    private func updateProfile(details: ObjectDetails) {
        profileIcon = details.objectIconImage
        
        if !dataLoaded {
            profileName = details.name
            dataLoaded = true
            $profileName
                .delay(for: 0.3, scheduler: DispatchQueue.main)
                .sink { [weak self] name in
                    self?.updateSpaceName(name: name)
                }
                .store(in: &subscriptions)
        }
    }
    
    private func updateSpaceName(name: String) {
        objectActionsService.updateBundledDetails(contextID: accountManager.account.info.profileObjectID, details: [
            .name(name)
        ])
    }
}
