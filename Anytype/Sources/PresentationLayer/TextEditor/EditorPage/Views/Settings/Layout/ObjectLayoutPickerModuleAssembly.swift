import Foundation
import UIKit

protocol ObjectLayoutPickerModuleAssemblyProtocol {
    func make(document: BaseDocumentProtocol) -> UIViewController
}

final class ObjectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ObjectLayoutPickerModuleAssemblyProtocol
    
    func make(document: BaseDocumentProtocol) -> UIViewController {
        let viewModel = ObjectLayoutPickerViewModel(
            document: document,
            detailsService: serviceLocator.detailsService()
        )
        return AnytypePopup(contentView: ObjectLayoutPicker(viewModel: viewModel))
    }
}
