import Combine
import Foundation
import UIKit

final class AccountInfoDataAccessor: ObservableObject {
    @Published var accountName: String?
    @Published var accountAvatar: UIImage?
    @Published var selectedColor: UIColor?
    
    var visibleAccountName: String {
        guard let name = accountName, !name.isEmpty else {
            return "Anytype User"
        }
        return name
    }
    
    var visibleSelectedColor: UIColor {
        selectedColor ?? .clear
    }
    
    private var obtainUserInformationSubscription: AnyCancellable?
    private let documentViewModel = BlocksViews.DocumentViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let middlewareConfigurationService = MiddlewareConfigurationService()
    private let blocksActionsService = BlockActionsServiceSingle()
    
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        let publisher = self.documentViewModel.defaultDetailsAccessorPublisher()
        
        publisher.map(\.title).map({$0?.value}).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.accountName = value
        }.store(in: &self.subscriptions)
        
        publisher.map(\.iconColor).map({$0?.value}).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.selectedColor = .init(hexString: value)
        }.store(in: &self.subscriptions)
        
        publisher.map(\.iconImage).map({$0?.value}).safelyUnwrapOptionals().flatMap({value in URLResolver.init().obtainImageURLPublisher(imageId: value).ignoreFailure()})
            .safelyUnwrapOptionals().flatMap({value in CoreLayer.Network.Image.Loader.init(value).imagePublisher}).receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.accountAvatar = value
        }.store(in: &self.subscriptions)
    }
    
    func obtainAccountInfo() {
        self.obtainUserInformationSubscription = self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration in
            self.blocksActionsService.open(contextID: configuration.profileBlockId, blockID: configuration.profileBlockId)
        }.sink(receiveCompletion: { (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                assertionFailure("obtainAccountInfo. Error has occured. \(error)")
            }
        }) { [weak self] value in
            self?.documentViewModel.open(value)
        }
    }
}
