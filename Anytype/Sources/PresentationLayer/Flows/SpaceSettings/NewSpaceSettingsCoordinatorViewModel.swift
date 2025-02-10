import Foundation
import SwiftUI
import Combine
import AnytypeCore
import Services

enum SpaceSettingsNavigationItem {
    case spaceDetails
}

@MainActor
final class NewSpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    @Published var path = NavigationPath()
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShareData: SpaceShareData?
    @Published var showSpaceMembersData: SpaceMembersData?
    @Published var showFiles = false
    @Published var showObjectTypeSearch = false
    @Published var dismiss = false
    @Published var showIconPickerSpaceId: StringIdentifiable?
    
    let workspaceInfo: AccountInfo
    var accountSpaceId: String { workspaceInfo.accountSpaceId }
    
    init(workspaceInfo: AccountInfo) {
        self.workspaceInfo = workspaceInfo
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onSpaceDetailsSelected() {
        path.append(SpaceSettingsNavigationItem.spaceDetails)
    }
    
    func onChangeIconSelected() {
        showIconPickerSpaceId = workspaceInfo.accountSpaceId.identifiable
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
    }
    
    func onPersonalizationSelected() {
        showPersonalization.toggle()
    }
    
    func onSpaceShareSelected() {
        showSpaceShareData = SpaceShareData(workspaceInfo: workspaceInfo, route: .settings)
    }
    
    func onSpaceMembersSelected() {
        showSpaceMembersData = SpaceMembersData(spaceId: workspaceInfo.accountSpaceId, route: .settings)
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
