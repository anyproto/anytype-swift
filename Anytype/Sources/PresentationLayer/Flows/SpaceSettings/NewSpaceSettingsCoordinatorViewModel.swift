import Foundation
import SwiftUI
import Combine
import AnytypeCore
import Services


@MainActor
final class NewSpaceSettingsCoordinatorViewModel: ObservableObject, NewSpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShareData: SpaceShareData?
    @Published var showSpaceMembersData: SpaceMembersData?
    @Published var showFiles = false
    
    var pageNavigation: PageNavigation?
    @Published var showDefaultObjectTypeSearch = false
    
    let workspaceInfo: AccountInfo
    var spaceId: String { workspaceInfo.accountSpaceId }
    
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
    
    func onSpaceShareSelected() {
        showSpaceShareData = SpaceShareData(spaceId: spaceId, route: .settings)
    }
    
    func onSpaceMembersSelected() {
        showSpaceMembersData = SpaceMembersData(spaceId: spaceId, route: .settings)
    }
    
    func onSelectDefaultObjectType(type: ObjectType) {
        objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId, route: .settings)
        showDefaultObjectTypeSearch = false
    }
    
    func onObjectTypesSelected() {
        pageNavigation?.open(.spaceInfo(.typeLibrary(spaceId: spaceId)))
    }
    
    func onBinSelected() {
        pageNavigation?.open(.editor(.bin(spaceId: spaceId)))
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
