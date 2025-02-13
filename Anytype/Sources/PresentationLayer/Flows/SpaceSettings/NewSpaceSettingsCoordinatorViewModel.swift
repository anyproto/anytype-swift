import Foundation
import SwiftUI
import Combine
import AnytypeCore
import Services


@MainActor
final class NewSpaceSettingsCoordinatorViewModel: ObservableObject, NewSpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShareData: SpaceShareData?
    @Published var showSpaceMembersData: SpaceMembersData?
    @Published var showFiles = false
    @Published var showObjectTypeSearch = false
    
    var pageNavigation: PageNavigation?
    
    let workspaceInfo: AccountInfo
    var accountSpaceId: String { workspaceInfo.accountSpaceId }
    
    init(workspaceInfo: AccountInfo) {
        self.workspaceInfo = workspaceInfo
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onSpaceDetailsSelected() {
        pageNavigation?.open(.settings(.spaceDetails(info: workspaceInfo)))
    }
    
    func onWallpaperSelected() {
        showWallpaperPicker.toggle()
    }
    
    func onDefaultObjectTypeSelected() {
        showObjectTypeSearch.toggle()
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
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
