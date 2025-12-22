import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol SpaceCreateModuleOutput: AnyObject {
    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput)
}

@MainActor
@Observable
final class SpaceCreateViewModel: LocalObjectIconPickerOutput {

    // MARK: - DI

    @ObservationIgnored
    let data: SpaceCreateData

    @ObservationIgnored @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @ObservationIgnored @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage

    // MARK: - State

    var spaceName = ""
    var spaceIcon: Icon
    var createLoadingState = false
    var dismiss: Bool = false

    @ObservationIgnored
    var fileData: FileData?
    @ObservationIgnored
    private let spaceIconOption: Int
    @ObservationIgnored
    private weak var output: (any SpaceCreateModuleOutput)?
    
    init(data: SpaceCreateData, output: (any SpaceCreateModuleOutput)?) {
        self.data = data
        self.output = output
        self.spaceIconOption = IconColorStorage.randomOption()
        self.spaceIcon = .object(.space(.name(name: "", iconOption: spaceIconOption, circular: data.spaceUxType.isChat)))
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
                accessType: .private,
                useCase: uxType.useCase,
                withChat: true,
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
                    _ = try await workspaceService.makeSharable(spaceId: spaceId)
                    _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
                } catch {}
            }
            
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace(spaceId: createResponse.spaceID, spaceUxType: uxType, route: .navigation)
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceCreate()
    }
    
    func updateNameIconIfNeeded(_ name: String) {
        guard fileData.isNil else { return }
        spaceIcon = .object(.space(.name(name: name, iconOption: spaceIconOption, circular: data.spaceUxType.isChat)))
    }
    
    func onIconTapped() {
        output?.onIconPickerSelected(fileData: fileData, output: self)
    }
    
    // MARK: - LocalObjectIconPickerOutput
    
    func localFileDataDidChanged(_ data: FileData?) {
        fileData = data
        if let path = fileData?.path {
            spaceIcon = .object(.space(.localPath(path, circular: self.data.spaceUxType.isChat)))
        } else {
            spaceIcon = .object(.space(.name(name: spaceName, iconOption: spaceIconOption, circular: self.data.spaceUxType.isChat)))
        }
    }
    
    // MARK: - Private
}
