import Foundation
import SwiftUI
import Services

protocol TextIconPickerModuleAssemblyProtocol: AnyObject {
    func make(contextId: BlockId, objectId: BlockId, onDismiss: @escaping () -> Void) -> AnyView
}

final class TextIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - TextIconPickerModuleAssemblyProtocol
    
    func make(contextId: BlockId, objectId: BlockId, onDismiss: @escaping () -> Void) -> AnyView {
        let viewModel = TextIconPickerViewModel(
            fileService: serviceLocator.fileService(),
            textService: serviceLocator.textService,
            contextId: contextId,
            objectId: objectId
        )

        let iconPicker = ObjectBasicIconPicker(viewModel: viewModel, onDismiss: onDismiss)
        
        return iconPicker.eraseToAnyView()
    }
}
