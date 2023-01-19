import Foundation
import UIKit
import SwiftUI

protocol ObjectCoverPickerModuleAssemblyProtocol {
    func make(document: BaseDocumentGeneralProtocol, objectId: String) -> UIViewController
}

final class ObjectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectCoverPickerModuleAssemblyProtocol
    
    func make(document: BaseDocumentGeneralProtocol, objectId: String) -> UIViewController {
        let viewModel = ObjectCoverPickerViewModel(
            document: document,
            objectId: objectId,
            fileService: serviceLocator.fileService(),
            detailsService: serviceLocator.detailsService(objectId: objectId)
        )
        
        let controller = UIHostingController(
            rootView: ObjectCoverPicker(viewModel: viewModel)
        )
        
        controller.rootView.onDismiss = { [weak controller] in
            controller?.dismiss(animated: true)
        }
        
        return controller
    }
}
