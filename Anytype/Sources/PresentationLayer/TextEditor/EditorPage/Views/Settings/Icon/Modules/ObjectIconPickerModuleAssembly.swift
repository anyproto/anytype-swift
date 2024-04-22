import Foundation
import UIKit
import SwiftUI

protocol ObjectIconPickerModuleAssemblyProtocol {
    func make(document: BaseDocumentGeneralProtocol) -> UIViewController
    
    // MARK: - Specific
    
    func makeSpaceView(document: BaseDocumentGeneralProtocol) -> UIViewController
}

final class ObjectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    // MARK: - ObjectIconPickerModuleAssemblyProtocol
    
    func make(
        document: BaseDocumentGeneralProtocol
    ) -> UIViewController {
        return makeInternal(document: document, actionHandler: ObjectIconActionHandler())
    }
    
    func makeSpaceView(
        document: BaseDocumentGeneralProtocol
    ) -> UIViewController {
        return makeInternal(document: document, actionHandler: SpaceViewIconActionHandler())
    }
    
    private func makeInternal(
        document: BaseDocumentGeneralProtocol,
        actionHandler: ObjectIconActionHandlerProtocol
    ) -> UIViewController {
        let viewModel = ObjectIconPickerViewModel(document: document, actionHandler: actionHandler)
        
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
}
