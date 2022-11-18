import Foundation
import UIKit
import SwiftUI

protocol ObjectIconPickerModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol) -> UIViewController
}

final class ObjectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol {
    
    // MARK: - ObjectIconPickerModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol) -> UIViewController {
        let viewModel = ObjectIconPickerViewModel(
            document: document,
            fileService: ServiceLocator.shared.fileService(),
            detailsService: ServiceLocator.shared.detailsService(objectId: document.objectId)
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
