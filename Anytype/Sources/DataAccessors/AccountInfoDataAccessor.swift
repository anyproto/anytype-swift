import Combine
import Foundation
import UIKit
import BlocksModels

final class AccountInfoDataAccessor: ObservableObject {
    @Published var name: String?
    @Published var avatarId: String?
    @Published var blockId: BlockId?
    
    private let defaultName = "Anytype User"
    
    private let document: BaseDocumentProtocol = BaseDocument()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let configurationService = MiddlewareConfigurationService()
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
                guard let self = self else {
                    return
                }
                self.name = accountName.isEmpty ? self.defaultName : accountName
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
        configurationService.obtainConfiguration { [weak self] config in
            guard let self = self else { return }
            
            self.blockId = config.profileBlockId
            
            self.blocksActionsService.open(contextID: config.profileBlockId, blockID: config.profileBlockId)
                .sinkWithDefaultCompletion("obtainAccountInfo") { [weak self] serviceSuccess in
                    self?.document.open(serviceSuccess)
                }.store(in: &self.subscriptions)
        }
    }
}
