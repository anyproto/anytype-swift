import Foundation
import UIKit

protocol UndoRedoModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol) -> UIViewController
}

final class UndoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - UndoRedoModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol) -> UIViewController {
        let viewModel = UndoRedoViewModel(objectId: document.objectId)
        let undoRedoView = UndoRedoView(viewModel: viewModel)
        
        let popupViewController = AnytypePopup(
            contentView: undoRedoView,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
        popupViewController.backdropView.backgroundColor = .clear
        
        viewModel.onErrorHandler = { [weak self] errorMessage in
            self?.uiHelpersDI.toastPresenter.show(
                message: .init(string: errorMessage), mode: .aboveView(popupViewController.surfaceView)
            )
        }
        

        return popupViewController
    }
}
