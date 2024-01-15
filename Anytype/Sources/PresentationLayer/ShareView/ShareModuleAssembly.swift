import Foundation
import SwiftUI
import Services
import AnytypeCore
import SharedContentManager

protocol ShareModuleAssemblyProtocol {
    @MainActor
    func make(
        onSearch: @escaping RoutingAction<SearchModuleModel>,
        onSpaceSearch: @escaping RoutingAction<(SpaceView) -> Void>,
        onClose: @escaping RoutingAction<Void>
    ) -> AnyView?
}

final class ShareModuleAssembly: ShareModuleAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ShareModuleAssemblyProtocol
    @MainActor
    func make(
        onSearch: @escaping RoutingAction<SearchModuleModel>,
        onSpaceSearch: @escaping RoutingAction<(SpaceView) -> Void>,
        onClose: @escaping RoutingAction<Void>
    ) -> AnyView? {
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
                contentViewModel = TextShareViewModel(
                    attributedText: attributedString,
                    onDocumentSelection: onSearch,
                    onSpaceSelection: onSpaceSearch
                )
            case .url(let url):
                contentViewModel = URLShareViewModel(
                    url: url,
                    onDocumentSelection: onSearch,
                    onSpaceSelection: onSpaceSearch
                )
            case .image:
                anytypeAssertionFailure("Images still are not supported")
                return nil
            }
        } else {
            anytypeAssertionFailure("Can't validate shared content from sharing extension")
            return nil
        }
        
        contentViewModel.selectedSpace = serviceLocator
            .workspaceStorage()
            .workspaces
            .first(where: {
                $0.targetSpaceId == serviceLocator.activeWorkspaceStorage().workspaceInfo.accountSpaceId
        })
        let viewModel = ShareViewModel(
            contentViewModel: contentViewModel,
            interactor: serviceLocator.sharedContentInteractor,
            contentManager: serviceLocator.sharedContentManager
        )
    
        viewModel.onClose = onClose
        
        let shareView = ShareView(viewModel: viewModel)
        
        return shareView.eraseToAnyView()
    }
}
