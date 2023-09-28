import Foundation
import UIKit
import SwiftUI

protocol ObjectIconPickerModuleAssemblyProtocol {
    func make(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
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
}
