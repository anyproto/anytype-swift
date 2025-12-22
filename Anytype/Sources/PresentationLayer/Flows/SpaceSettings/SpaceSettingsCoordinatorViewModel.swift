import Foundation
import SwiftUI
import AnytypeCore
import Services


@MainActor
@Observable
final class SpaceSettingsCoordinatorViewModel: SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    @ObservationIgnored @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol

    var showRemoteStorage = false
    var showWallpaperPicker = false
    var showSpaceShareData: SpaceShareData?
    var spaceNotificationsSettingsModuleData: SpaceNotificationsSettingsModuleData?
    var spaceTypeChangeData: SpaceTypeChangeData?
    var showFiles = false

    @ObservationIgnored
    var pageNavigation: PageNavigation?
    var showDefaultObjectTypeSearch = false

    let workspaceInfo: AccountInfo
    var spaceId: String { workspaceInfo.accountSpaceId }

    @ObservationIgnored
    private var spaceShareCompletion: (() -> Void)?
    
    init(workspaceInfo: AccountInfo) {
        self.workspaceInfo = workspaceInfo
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onWallpaperSelected() {
        showWallpaperPicker.toggle()
    }
    
    func onDefaultObjectTypeSelected() {
        showDefaultObjectTypeSearch.toggle()
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
    }
    
    func onSpaceShareSelected(_ completion: @escaping () -> Void) {
        spaceShareCompletion = completion
        showSpaceShareData = SpaceShareData(spaceId: spaceId, route: .settings)
    }
    
    func onSpaceShareDismissed() {
        spaceShareCompletion?()
        spaceShareCompletion = nil
    }
    
    func onNotificationsSelected() {
        spaceNotificationsSettingsModuleData = SpaceNotificationsSettingsModuleData(spaceId: spaceId)
    }
    
    func onSelectDefaultObjectType(type: ObjectType) {
        objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId, route: .settings)
        showDefaultObjectTypeSearch = false
    }
    
    func onObjectTypesSelected() {
        pageNavigation?.open(.spaceInfo(.typeLibrary(spaceId: spaceId)))
    }
    
    func onPropertiesSelected() {
        pageNavigation?.open(.spaceInfo(.propertiesLibrary(spaceId: spaceId)))
    }
    
    func onBinSelected() {
        pageNavigation?.open(.editor(.bin(spaceId: spaceId)))
    }
    
    func onSpaceUxTypeSelected() {
        spaceTypeChangeData = SpaceTypeChangeData(spaceId: spaceId)
    }
    
    // MARK: - RemoteStorageModuleOutput
    
    func onManageFilesSelected() {
        showFiles = true
    }
    
    // MARK: - PersonalizationModuleOutput
    
    func onDefaultTypeSelected() {
        showDefaultObjectTypeSearch = true
    }
    
    func onWallpaperChangeSelected() {
        showWallpaperPicker.toggle()
    }
}
