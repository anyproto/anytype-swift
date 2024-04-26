import Foundation
import UIKit
import SwiftUI

protocol ObjectIconPickerModuleAssemblyProtocol {
    func make(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) -> UIViewController
    
    // MARK: - Specific
    
    func makeSpaceView(
        document: BaseDocumentGeneralProtocol
    ) -> UIViewController
}

final class ObjectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    // MARK: - ObjectIconPickerModuleAssemblyProtocol
    
    func make(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) -> UIViewController {
        let viewModel = ObjectIconPickerViewModel(
            document: document,
            onIconAction: onIconAction
        )
        
        let controller = UIHostingController(
            rootView: ObjectIconPicker(viewModel: viewModel)
        )
        
        controller.rootView.dismissHandler = DismissHandler(
            onDismiss:  { [weak controller] in
                controller?.dismiss(animated: true)
            }
        )
        
        return controller
    }
    
    func makeSpaceView(
        document: BaseDocumentGeneralProtocol
    ) -> UIViewController {
        // TODO: Use space view
        let internalViewModel = SpaceViewIconInternalViewModel(workspaceService: serviceLocator.workspaceService(), fileService: serviceLocator.fileService())
        let module = make(document: document) { action in
            internalViewModel.handleIconAction(spaceId: document.details?.targetSpaceId ?? "", action: action)
        }
        return module
    }
}
