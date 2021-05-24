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
    
    private let middlewareConfigurationService = MiddlewareConfigurationService()
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
            .map { $0[.name] }
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
            .map { $0[.iconImage] }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] imageId in
                self?.avatarId = imageId.isEmpty ? nil : imageId
            }
            .store(in: &self.subscriptions)
    }
    
    private func obtainAccountInfo() {
        // Make async
        middlewareConfigurationService.obtainConfiguration().receiveOnMain().flatMap { [weak self] configuration -> AnyPublisher<ServiceSuccess, Error> in
            guard let self = self else {
                return .empty()
            }
            
            self.blockId = configuration.profileBlockId
            return self.blocksActionsService.open(contextID: configuration.profileBlockId, blockID: configuration.profileBlockId)
        }.sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case let .failure(error):
                assertionFailure("obtainAccountInfo. Error has occured. \(error)")
            }
        }) { [weak self] serviceSuccess in
            self?.document.open(serviceSuccess)
        }.store(in: &subscriptions)
    }
}
