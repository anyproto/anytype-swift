import SwiftUI

protocol SetViewPickerModuleAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        output: SetViewPickerCoordinatorOutput?
    ) -> AnyView
}

final class SetViewPickerModuleAssembly: SetViewPickerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SetViewPickerModuleAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        output: SetViewPickerCoordinatorOutput?
    ) -> AnyView {
        let dataviewService = serviceLocator.dataviewService(
            objectId: setDocument.objectId,
            blockId: setDocument.inlineParameters?.blockId
        )
        return SetViewPicker(
            viewModel: SetViewPickerViewModel(
                setDocument: setDocument,
                dataviewService: dataviewService,
                output: output
            )
        ).eraseToAnyView()
    }
}
