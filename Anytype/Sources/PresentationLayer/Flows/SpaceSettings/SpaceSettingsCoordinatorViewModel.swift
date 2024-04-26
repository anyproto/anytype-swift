import Foundation
import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    private let navigationContext: NavigationContextProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let urlOpener: URLOpenerProtocol
    private let documentService: OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShare = false
    @Published var showSpaceMembers = false
    @Published var dismiss = false
    
    var accountSpaceId: String
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        navigationContext: NavigationContextProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        urlOpener: URLOpenerProtocol,
        documentService: OpenedDocumentsProviderProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.objectTypeSearchModuleAssembly = objectTypeSearchModuleAssembly
        self.objectTypeProvider = objectTypeProvider
        self.urlOpener = urlOpener
        self.documentService = documentService
        self.accountSpaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        startSubscriptions()
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = objectIconPickerModuleAssembly.makeSpaceView(document: document)
        navigationContext.present(module)
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
    }
    
    func onPersonalizationSelected() {
        showPersonalization.toggle()
    }
    
    func onSpaceShareSelected() {
        showSpaceShare.toggle()
    }
    
    func onSpaceMembersSelected() {
        showSpaceMembers.toggle()
    }
    
    // MARK: - RemoteStorageModuleOutput
    
    func onManageFilesSelected() {
        let module = widgetObjectListModuleAssembly.makeFiles()
        navigationContext.present(module)
    }
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
    
    // MARK: - PersonalizationModuleOutput
    
    func onDefaultTypeSelected() {
        let module = objectTypeSearchModuleAssembly.makeDefaultTypeSearch(
            title: Loc.chooseDefaultObjectType,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            showPins: false,
            showLists: false,
            showFiles: false,
            incudeNotForCreation: false
        ) { [weak self] type in
            self?.objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId, route: .settings)
            self?.navigationContext.dismissTopPresented(animated: true)
        }
        navigationContext.present(module)
    }
    
    func onWallpaperChangeSelected() {
        showWallpaperPicker.toggle()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        activeWorkspaceStorage.workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] info in
                guard let self else { return }
                if info.accountSpaceId != accountSpaceId {
                    dismissAll()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func dismissAll() {
        showRemoteStorage = false
        showPersonalization = false
        showWallpaperPicker = false
        dismiss.toggle()
    }
}
