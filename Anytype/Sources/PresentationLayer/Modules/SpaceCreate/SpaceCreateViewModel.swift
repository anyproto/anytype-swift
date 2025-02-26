import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject, LocalObjectIconPickerOutput {
    
    // MARK: - DI
    
    let data: SpaceCreateData
    
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceIcon: Icon
    @Published var spaceAccessType: SpaceAccessType = .private
    @Published var createLoadingState = false
    @Published var showLocalIconPicker = false
    @Published var dismiss: Bool = false
    
    var fileData: FileData?
    private let spaceIconOption: Int
    
    init(data: SpaceCreateData) {
        self.data = data
        self.spaceIconOption = IconColorStorage.randomOption()
        self.spaceIcon = .object(.space(.name(name: "", iconOption: spaceIconOption)))
    }
    
    func onTapCreate() {
        guard !createLoadingState else { return }
        Task {
            createLoadingState = true
            defer {
                createLoadingState = false
            }
            let spaceId = try await workspaceService.createSpace(
                name: spaceName,
                iconOption: spaceIconOption,
                accessType: spaceAccessType,
                useCase: .empty,
                withChat: FeatureFlags.homeSpaceLevelChat,
                uxType: data.spaceUxType
            )
            
            if let fileData {
                let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: fileData, origin: .none)
                try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
            }
            
            try await spaceSetupManager.setActiveSpace(sceneId: data.sceneId, spaceId: spaceId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace(route: .navigation)
            dismissForLegacyOS()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceCreate()
    }
    
    func updateNameIconIfNeeded(_ name: String) {
        guard fileData.isNil else { return }
        spaceIcon = .object(.space(.name(name: name, iconOption: spaceIconOption)))
    }
    
    // MARK: - LocalObjectIconPickerOutput
    
    func localFileDataDidChanged(_ data: FileData?) {
        fileData = data
        if let path = fileData?.path {
            spaceIcon = .object(.space(.localPath(path)))
        } else {
            spaceIcon = .object(.space(.name(name: spaceName, iconOption: spaceIconOption)))
        }
    }
    
    // MARK: - Private
    
    @available(iOS, deprecated: 17)
    private func dismissForLegacyOS() {
        if #available(iOS 17, *) {
        } else {
            dismiss.toggle()
        }
    }
}
