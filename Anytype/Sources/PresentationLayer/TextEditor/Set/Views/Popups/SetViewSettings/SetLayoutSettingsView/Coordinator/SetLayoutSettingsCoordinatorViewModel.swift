import SwiftUI

@MainActor
protocol SetLayoutSettingsCoordinatorOutput: AnyObject {
    func onImagePreviewTap(completion: @escaping (String) -> Void)
}

@MainActor
final class SetLayoutSettingsCoordinatorViewModel: ObservableObject, SetLayoutSettingsCoordinatorOutput {
    @Published var imagePreviewData: ImagePreviewData?
    
    private let setDocument: SetDocumentProtocol
    private let setLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol
    private let setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        setLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol,
        setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.setLayoutSettingsViewAssembly = setLayoutSettingsViewAssembly
        self.setViewSettingsImagePreviewModuleAssembly = setViewSettingsImagePreviewModuleAssembly
    }
    
    func list() -> AnyView {
        setLayoutSettingsViewAssembly.make(setDocument: setDocument)
    }
    
    // MARK: - SetLayoutSettingsCoordinatorOutput
    
    func onImagePreviewTap(completion: @escaping (String) -> Void) {
        imagePreviewData = ImagePreviewData(completion: completion)
    }
    
    func imagePreview(data: ImagePreviewData) -> AnyView {
        setViewSettingsImagePreviewModuleAssembly.make(
            setDocument: setDocument,
            onSelect: data.completion
        )
    }
}

extension SetLayoutSettingsCoordinatorViewModel {
    struct ImagePreviewData: Identifiable {
        let id = UUID()
        let completion: (String) -> Void
    }
}

