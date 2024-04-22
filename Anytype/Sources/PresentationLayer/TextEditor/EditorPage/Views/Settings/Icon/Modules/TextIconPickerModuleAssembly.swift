import Foundation
import SwiftUI
import Services

protocol TextIconPickerModuleAssemblyProtocol: AnyObject {
    func make(contextId: String, objectId: String, spaceId: String) -> AnyView
}

final class TextIconPickerModuleAssembly: TextIconPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - TextIconPickerModuleAssemblyProtocol
    
    func make(contextId: String, objectId: String, spaceId: String) -> AnyView {
        let viewModel = TextIconPickerViewModel(
            fileService: serviceLocator.fileService(),
            textServiceHandler: serviceLocator.textServiceHandler(),
            contextId: contextId,
            objectId: objectId,
            spaceId: spaceId
        )

        let iconPicker = ObjectBasicIconPicker(viewModel: viewModel)
        
        return iconPicker.eraseToAnyView()
    }
}
