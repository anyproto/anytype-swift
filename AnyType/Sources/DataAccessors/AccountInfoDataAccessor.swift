import Combine
import Foundation
import UIKit
import BlocksModels

final class AccountInfoDataAccessor: ObservableObject {
    @Published var name: String
    @Published var avatar: UIImage?
    @Published var blockId: BlockId?
    
    private let defaultName = "Anytype User"
    
    private let documentViewModel: DocumentViewModelProtocol = DocumentViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let middlewareConfigurationService = MiddlewareConfigurationService()
    private let blocksActionsService = BlockActionsServiceSingle()
    
    
    init() {
        name = defaultName
        
        setUpSubscriptions()
        obtainAccountInfo()
    }
    
    private func setUpSubscriptions() {
        setUpNameSubscription()
        setUpImageSubscription()
    }
    
    private func setUpNameSubscription() {
        documentViewModel.pageDetailsPublisher().map {$0.title?.value}.safelyUnwrapOptionals().receive(on: DispatchQueue.main).sink { [weak self] accountName in
            guard let self = self else {
                return
            }
            
            self.name = accountName.isEmpty ? self.defaultName : accountName
        }.store(in: &self.subscriptions)
    }
    
    private func setUpImageSubscription() {
        documentViewModel.pageDetailsPublisher().map(\.iconImage?.value).safelyUnwrapOptionals()
            .receive(on: DispatchQueue.main).compactMap { [weak self] imageId in
                guard imageId.isEmpty == false else {
                    self?.avatar = nil
                    return nil
                }
                
            return imageId
        }.flatMap { imageId in
            URLResolver().obtainImageURLPublisher(imageId: imageId).ignoreFailure().eraseToAnyPublisher()
        }.safelyUnwrapOptionals().flatMap { imageUrl in
            ImageLoaderObject(imageUrl).imagePublisher
        }.receive(on: DispatchQueue.main).sink { [weak self] avatar in
            self?.avatar = avatar
        }.store(in: &self.subscriptions)
    }
    
    private func obtainAccountInfo() {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration -> AnyPublisher<ServiceSuccess, Error> in
            self.blockId = configuration.profileBlockId
            return self.blocksActionsService.open(contextID: configuration.profileBlockId, blockID: configuration.profileBlockId)
        }.sink(receiveCompletion: { (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                assertionFailure("obtainAccountInfo. Error has occured. \(error)")
            }
        }) { [weak self] value in
            self?.documentViewModel.open(value)
        }.store(in: &subscriptions)
    }
}
