import Combine
import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class AccountInfoDataAccessor: ObservableObject {
    
    @Published private(set) var profileBlockId = MiddlewareConfigurationService.shared.configuration().profileBlockId
    @Published private(set) var name: String?
    @Published private(set) var avatarId: String?
    
    private let document: BaseDocumentProtocol = BaseDocument()
    private var subscriptions: [AnyCancellable] = []
    
    private let blocksActionsService = BlockActionsServiceSingle()
    
    init() {        
        setUpSubscriptions()
        obtainAccountInfo()
    }
    
    private func setUpSubscriptions() {
        setUpNameSubscription()
        setUpImageSubscription()
    }
    
    private func setUpNameSubscription() {
        document.pageDetailsPublisher()
            .safelyUnwrapOptionals()
            .map { $0.name }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] accountName in
                self?.name = accountName.isEmpty ? Constants.defaultName : accountName
            }
            .store(in: &self.subscriptions)
    }
    
    private func setUpImageSubscription() {
        document.pageDetailsPublisher()
            .safelyUnwrapOptionals()
            .map { $0.iconImage }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] imageId in
                self?.avatarId = imageId.isEmpty ? nil : imageId
            }
            .store(in: &self.subscriptions)
    }
    
    private func obtainAccountInfo() {
        guard
            let response = blocksActionsService.open(
                contextId: profileBlockId,
                blockId: profileBlockId
            )
        else {
            return
        }
        
        document.open(response)
    }
}

private extension AccountInfoDataAccessor {
    
    enum Constants {
        static let defaultName = "Anytype User"
    }
    
}
