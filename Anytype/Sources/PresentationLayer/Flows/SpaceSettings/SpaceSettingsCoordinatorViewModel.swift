import Foundation
import SwiftUI

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput {

    private let spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let documentService: DocumentServiceProtocol
    
    init(
        spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.spaceSettingsModuleAssembly = spaceSettingsModuleAssembly
        self.navigationContext = navigationContext
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.documentService = documentService
    }
    
    func settingsModule() -> AnyView {
        spaceSettingsModuleAssembly.make(output: self)
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = objectIconPickerModuleAssembly.make(document: document, objectId: objectId)
        navigationContext.present(module)
    }
}
