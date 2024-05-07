import Foundation
import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    private let navigationContext: NavigationContextProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShare = false
    @Published var showSpaceMembers = false
    @Published var dismiss = false
    @Published var showIconPickerSpaceViewId: StringIdentifiable?
    
    var accountSpaceId: String
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        navigationContext: NavigationContextProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.navigationContext = navigationContext
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.urlOpener = urlOpener
        self.activeWorkspaceStorage = Container.shared.activeWorkspaceStorage.resolve()
        self.accountSpaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        startSubscriptions()
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onChangeIconSelected(objectId: String) {
        showIconPickerSpaceViewId = objectId.identifiable
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
        let view = ObjectTypeSearchView(
            title: Loc.chooseDefaultObjectType,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            settings: .spaceDefaultObject
        ) { [weak self] type in
            self?.objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId, route: .settings)
            self?.navigationContext.dismissTopPresented(animated: true)
        }
        navigationContext.present(view)
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
