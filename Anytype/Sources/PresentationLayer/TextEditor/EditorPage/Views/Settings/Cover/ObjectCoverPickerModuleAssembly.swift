import Foundation
import UIKit
import SwiftUI

protocol ObjectCoverPickerModuleAssemblyProtocol {
    func make(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) -> UIViewController
}

final class ObjectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectCoverPickerModuleAssemblyProtocol
    
    func make(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) -> UIViewController {
        let viewModel = ObjectCoverPickerViewModel(
            document: document,
            fileService: serviceLocator.fileService(),
            detailsService: serviceLocator.detailsService(objectId: document.objectId),
            onCoverAction: onCoverAction
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
