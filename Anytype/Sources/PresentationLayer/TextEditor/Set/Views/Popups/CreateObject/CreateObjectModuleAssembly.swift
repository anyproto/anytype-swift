import Foundation
import UIKit
import Services

enum CreateObjectTitleInputType {
    case writeToBlock(blockId: String) // For layouts withouts Name (Note)
    case writeToRelationName // For the rest of layouts
    
    case none // Layouts without title input like Bookmark
}

@MainActor
protocol CreateObjectModuleAssemblyProtocol {
    
    func makeCreateObject(
        objectId: String,
        titleInputType: CreateObjectTitleInputType,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) -> UIViewController
    
    func makeCreateBookmark(
        spaceId: String,
        collectionId: String?,
        closeAction: @escaping (_ details: ObjectDetails?) -> Void
    ) -> UIViewController
}

@MainActor
final class CreateObjectModuleAssembly: CreateObjectModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - CreateObjectModuleAssemblyProtocol
    
    @MainActor
    func makeCreateObject(
        objectId: String,
        titleInputType: CreateObjectTitleInputType,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = CreateObjectViewModel(
            objectId: objectId,
            titleInputType: titleInputType,
            relationService: serviceLocator.relationService(),
            textServiceHandler: serviceLocator.textServiceHandler(),
            openToEditAction: openToEditAction,
            closeAction: closeAction
        )
        return make(viewModel: viewModel)
    }
    
    func makeCreateBookmark(spaceId: String, collectionId: String?, closeAction: @escaping (_ details: ObjectDetails?) -> Void) -> UIViewController {
        let viewModel = CreateBookmarkViewModel(
            spaceId: spaceId,
            collectionId: collectionId,
            bookmarkService: serviceLocator.bookmarkService(),
            objectActionsService: serviceLocator.objectActionsService(),
            closeAction: closeAction
        )
        return make(viewModel: viewModel)
    }
    
    // MARK: - Private
    
    private func make(viewModel: CreateObjectViewModelProtocol) -> UIViewController {
        let view = CreateObjectView(viewModel: viewModel)
        return AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true ),
            showKeyboard: true
        )
    }
}
