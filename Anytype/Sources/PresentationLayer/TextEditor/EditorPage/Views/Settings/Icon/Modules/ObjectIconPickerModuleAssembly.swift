import Foundation
import UIKit
import SwiftUI

protocol ObjectIconPickerModuleAssemblyProtocol {
    func make(document: BaseDocumentGeneralProtocol, objectId: String) -> UIViewController
}

final class ObjectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }

    // MARK: - ObjectIconPickerModuleAssemblyProtocol
    
    func make(document: BaseDocumentGeneralProtocol, objectId: String) -> UIViewController {
        let viewModel = ObjectIconPickerViewModel(
            document: document,
            objectId: objectId,
            fileService: serviceLocator.fileService(),
            detailsService: serviceLocator.detailsService(objectId: objectId)
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
