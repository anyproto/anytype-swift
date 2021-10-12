import Combine
import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class AccountInfoDataAccessor: ObservableObject {
    
    @Published private(set) var profileBlockId: BlockId
    @Published private(set) var name: String?
    @Published private(set) var avatarId: String?
    
    private let document: BaseDocumentProtocol
    private var subscriptions: [AnyCancellable] = []
        
    init() {
        let blockId = MiddlewareConfigurationService.shared.configuration().profileBlockId
        profileBlockId = blockId
        document = BaseDocument(objectId: blockId)
        document.open()
        
        setUpSubscriptions()
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
    
}

private extension AccountInfoDataAccessor {
    
    enum Constants {
        static let defaultName = "Anytype User"
    }
    
}
