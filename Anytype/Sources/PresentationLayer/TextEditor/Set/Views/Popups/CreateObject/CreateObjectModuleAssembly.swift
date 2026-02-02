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
}

@MainActor
final class CreateObjectModuleAssembly: CreateObjectModuleAssemblyProtocol {
    
    nonisolated init() { }
    
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
            openToEditAction: openToEditAction,
            closeAction: closeAction
        )
        return make(viewModel: viewModel)
    }
    
    // MARK: - Private
    
    private func make(viewModel: some CreateObjectViewModelProtocol) -> UIViewController {
        let view = CreateObjectView(viewModel: viewModel)
        return AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true ),
            showKeyboard: true
        )
    }
}
