import Combine
import Foundation
import UIKit
import BlocksModels

final class AccountInfoDataAccessor: ObservableObject {
    @Published var accountName: String?
    @Published var accountAvatar: UIImage?
    @Published var selectedColor: UIColor?
    @Published var profileBlockId: BlockId?
    
    var visibleAccountName: String {
        guard let name = accountName, !name.isEmpty else {
            return "Anytype User"
        }
        return name
    }
    
    var visibleSelectedColor: UIColor {
        selectedColor ?? .clear
    }
    
    private let documentViewModel = BlocksViews.DocumentViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let middlewareConfigurationService = MiddlewareConfigurationService()
    private let blocksActionsService = BlockActionsServiceSingle()
    
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        let publisher = self.documentViewModel.defaultPageDetailsPublisher()
        
        publisher.map {$0.title?.value}.safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.accountName = value
        }.store(in: &self.subscriptions)
        
        publisher.map { $0.iconColor?.value}.safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.selectedColor = .init(hexString: value)
        }.store(in: &self.subscriptions)
        
        publisher.map {$0.iconImage?.value}.safelyUnwrapOptionals().flatMap({value in URLResolver.init().obtainImageURLPublisher(imageId: value).ignoreFailure()})
            .safelyUnwrapOptionals().flatMap({value in CoreLayer.Network.Image.Loader.init(value).imagePublisher}).receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.accountAvatar = value
        }.store(in: &self.subscriptions)
    }
    
    func obtainAccountInfo() {        
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration -> AnyPublisher<ServiceSuccess, Error> in
            self.profileBlockId = configuration.homeBlockID
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
