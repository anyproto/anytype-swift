import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
protocol SpaceCreateModuleOutput: AnyObject {
    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput)
}

@MainActor
final class SpaceCreateViewModel: ObservableObject, LocalObjectIconPickerOutput {
    
    // MARK: - DI
    
    let data: SpaceCreateData
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.chatInviteStateService)
    private var chatInviteStateService: any ChatInviteStateServiceProtocol
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceIcon: Icon
    @Published var spaceAccessType: SpaceAccessType = .private
    @Published var createLoadingState = false
    @Published var dismiss: Bool = false
    
    var fileData: FileData?
    private let spaceIconOption: Int
    private weak var output: (any SpaceCreateModuleOutput)?
    
    init(data: SpaceCreateData, output: (any SpaceCreateModuleOutput)?) {
        self.data = data
        self.output = output
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
            let uxType = data.spaceUxType
            let createResponse = try await workspaceService.createSpace(
                name: spaceName,
                iconOption: spaceIconOption,
                accessType: spaceAccessType,
                useCase: uxType.useCase,
                withChat: FeatureFlags.homeSpaceLevelChat,
                uxType: uxType
            )
            
            let spaceId = createResponse.spaceID
                        
            if let fileData {
                let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: fileData, origin: .none)
                try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
            }
            
            if uxType.isChat {
                // Do not rethrow error to main flow
                do {
                    chatInviteStateService.setShouldShowInvite(for: spaceId)
                    _ = try await workspaceService.makeSharable(spaceId: spaceId)
                    _ = try await workspaceService.generateInvite(spaceId: spaceId)
                } catch {}
            }
            
            if FeatureFlags.openWelcomeObject {
                if createResponse.startingObjectID.isNotEmpty {
                    appActionStorage.action = .openObject(objectId: createResponse.startingObjectID, spaceId: spaceId)
                } else {
                    try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
                }
            } else {
                try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace(route: .navigation, spaceUxType: uxType)
            
            if createResponse.startingObjectID.isNotEmpty {
                appActionStorage.action = .openObject(objectId: createResponse.startingObjectID, spaceId: spaceId)
            }
            
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
    
    func onIconTapped() {
        output?.onIconPickerSelected(fileData: fileData, output: self)
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
