import Foundation
import SwiftUI
import Services
import AnytypeCore

protocol ShareModuleAssemblyProtocol {
    @MainActor
    func make(
        onSearch: @escaping RoutingAction<(String, [DetailsLayout], (ObjectSearchData) -> Void)>,
        onClose: @escaping RoutingAction<Void>
    ) -> ShareView?
}

final class ShareModuleAssembly: ShareModuleAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ShareModuleAssemblyProtocol
    @MainActor
    func make(
        onSearch: @escaping RoutingAction<(String, [DetailsLayout], (ObjectSearchData) -> Void)>,
        onClose: @escaping RoutingAction<Void>
    ) -> ShareView? {
        let sharedContent: [SharedContent]
        do {
            sharedContent = try serviceLocator.sharedContentManager.getSharedContent()
        } catch {
            anytypeAssertionFailure("Can't validate shared content from sharing extension: \(error)")
            return nil
        }
    
        let contentViewModel: ShareViewModelProtocol
        if sharedContent.count == 1, let content = sharedContent.first {
            switch content {
            case .text(let attributedString):
                contentViewModel = TextShareViewModel(attributedText: attributedString, onDocumentSelection: onSearch)
            case .url(let url):
                contentViewModel = URLShareViewModel(url: url, onDocumentSelection: onSearch)
            case .image:
                anytypeAssertionFailure("Images still are not supported")
                return nil
            }
        } else {
            anytypeAssertionFailure("Can't validate shared content from sharing extension")
            return nil
        }
        
        let viewModel = ShareViewModel(
            contentViewModel: contentViewModel,
            interactor: serviceLocator.sharedContentInteractor,
            contentManager: serviceLocator.sharedContentManager
        )
    
        viewModel.onClose = onClose
        
        return ShareView(viewModel: viewModel)
    }
}
