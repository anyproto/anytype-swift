import Foundation
import SwiftUI
import Combine
import AnytypeCore
import Services

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var showSpaceShare = false
    @Published var showSpaceMembers = false
    @Published var showFiles = false
    @Published var showObjectTypeSearch = false
    @Published var dismiss = false
    @Published var showIconPickerSpaceViewId: StringIdentifiable?
    
    lazy var accountSpaceId: String = {
        activeWorkspaceStorage.workspaceInfo.accountSpaceId
    }()
    
    private var subscriptions = [AnyCancellable]()
    
    init() {
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
