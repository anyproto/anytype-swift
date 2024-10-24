import Foundation
import SwiftUI
import Combine
import AnytypeCore
import Services

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShareData: AccountInfo?
    @Published var showSpaceMembersDataSpaceId: StringIdentifiable?
    @Published var showFiles = false
    @Published var showObjectTypeSearch = false
    @Published var dismiss = false
    @Published var showIconPickerSpaceViewId: StringIdentifiable?
    
    let workspaceInfo: AccountInfo
    var accountSpaceId: String { workspaceInfo.accountSpaceId }
    
    init(workspaceInfo: AccountInfo) {
        self.workspaceInfo = workspaceInfo
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
        showSpaceShareData = workspaceInfo
    }
    
    func onSpaceMembersSelected() {
        showSpaceMembersDataSpaceId = workspaceInfo.accountSpaceId.identifiable
    }
    
    func onSelectDefaultObjectType(type: ObjectType) {
        objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId, route: .settings)
        showObjectTypeSearch = false
    }
    
    // MARK: - RemoteStorageModuleOutput
    
    func onManageFilesSelected() {
        showFiles = true
    }
    
    // MARK: - PersonalizationModuleOutput
    
    func onDefaultTypeSelected() {
        showObjectTypeSearch = true
    }
    
    func onWallpaperChangeSelected() {
        showWallpaperPicker.toggle()
    }
}
