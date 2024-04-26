import SwiftUI

@MainActor
protocol SetLayoutSettingsCoordinatorOutput: AnyObject {
    func onImagePreviewTap(completion: @escaping (String) -> Void)
    func onGroupByTap(completion: @escaping (String) -> Void)
}

@MainActor
final class SetLayoutSettingsCoordinatorViewModel: ObservableObject, SetLayoutSettingsCoordinatorOutput {
    @Published var imagePreviewData: SheetData?
    @Published var groupByData: SheetData?
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let setLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol
    private let setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    private let setViewSettingsGroupByModuleAssembly: SetViewSettingsGroupByModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        setLayoutSettingsViewAssembly: SetLayoutSettingsViewAssemblyProtocol,
        setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol,
        setViewSettingsGroupByModuleAssembly: SetViewSettingsGroupByModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.setLayoutSettingsViewAssembly = setLayoutSettingsViewAssembly
        self.setViewSettingsImagePreviewModuleAssembly = setViewSettingsImagePreviewModuleAssembly
        self.setViewSettingsGroupByModuleAssembly = setViewSettingsGroupByModuleAssembly
    }
    
    func list() -> AnyView {
        setLayoutSettingsViewAssembly.make(
            setDocument: setDocument,
            viewId: viewId,
            output: self
        )
    }
    
    // MARK: - SetLayoutSettingsCoordinatorOutput
    
    func onImagePreviewTap(completion: @escaping (String) -> Void) {
        imagePreviewData = SheetData(completion: completion)
    }
    
    func imagePreview(data: SheetData) -> AnyView {
        setViewSettingsImagePreviewModuleAssembly.make(
            setDocument: setDocument,
            onSelect: data.completion
        )
    }
    
    func onGroupByTap(completion: @escaping (String) -> Void) {
        groupByData = SheetData(completion: completion)
    }
    
    func groupByView(data: SheetData) -> AnyView {
        setViewSettingsGroupByModuleAssembly.make(
            setDocument: setDocument,
            onSelect: data.completion
        )
    }
}

extension SetLayoutSettingsCoordinatorViewModel {
    struct SheetData: Identifiable {
        let id = UUID()
        let completion: (String) -> Void
    }
}

