import Foundation
import SwiftUI

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput {

    private let spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let remoteStorageModuleAssembly: RemoteStorageModuleAssemblyProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let documentService: DocumentServiceProtocol
    
    @Published var showRemoteStorage = false
    
    init(
        spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        remoteStorageModuleAssembly: RemoteStorageModuleAssemblyProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.spaceSettingsModuleAssembly = spaceSettingsModuleAssembly
        self.navigationContext = navigationContext
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.remoteStorageModuleAssembly = remoteStorageModuleAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.urlOpener = urlOpener
        self.documentService = documentService
    }
    
    func settingsModule() -> AnyView {
        return spaceSettingsModuleAssembly.make(output: self)
    }
    
    func remoteStorageModule() -> AnyView {
        return remoteStorageModuleAssembly.make(output: self)
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = objectIconPickerModuleAssembly.make(document: document, objectId: objectId)
        navigationContext.present(module)
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
    }
    
    // MARK: - RemoteStorageModuleOutput
    
    func onManageFilesSelected() {
        let module = widgetObjectListModuleAssembly.makeFiles()
        navigationContext.present(module)
    }
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
}
