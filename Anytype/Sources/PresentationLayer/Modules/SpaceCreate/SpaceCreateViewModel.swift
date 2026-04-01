import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol SpaceCreateModuleOutput: AnyObject {
    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput)
    func onSpaceCreated(spaceId: String) async throws
}

@MainActor
@Observable
final class SpaceCreateViewModel: LocalObjectIconPickerOutput {

    // MARK: - DI

    @ObservationIgnored
    let data: SpaceCreateData

    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @ObservationIgnored @Injected(\.pendingShareService)
    private var pendingShareService: any PendingShareServiceProtocol
    @ObservationIgnored @Injected(\.networkStatusProvider)
    private var networkStatusProvider: any NetworkStatusProviderProtocol

    // MARK: - State

    var spaceName = ""
    var spaceIcon: Icon
    var dismiss: Bool = false
    var isConnected: Bool = true

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
        let isCircular = data.channelType == nil && data.spaceUxType.isChat
        self.spaceIcon = .object(.space(.name(name: "", iconOption: spaceIconOption, circular: isCircular)))
        self.isConnected = networkStatusProvider.isConnected
    }
    
    func onTapCreate() async throws {
        let spaceId: String

        if let channelType = data.channelType {
            spaceId = try await createChannel(channelType: channelType)
        } else {
            spaceId = try await createLegacySpace()
        }

        if let fileData {
            let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: fileData, origin: .none)
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AnytypeAnalytics.instance().logCreateSpace(spaceId: spaceId, spaceUxType: data.spaceUxType, route: .navigation)
        try await output?.onSpaceCreated(spaceId: spaceId)
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceCreate()
        isConnected = networkStatusProvider.isConnected
    }

    func startNetworkObservation() async {
        for await connected in networkStatusProvider.isConnectedPublisher.values {
            isConnected = connected
        }
    }
    
    func updateNameIconIfNeeded(_ name: String) {
        guard fileData.isNil else { return }
        let isCircular = data.channelType == nil && data.spaceUxType.isChat
        spaceIcon = .object(.space(.name(name: name, iconOption: spaceIconOption, circular: isCircular)))
    }
    
    func onIconTapped() {
        output?.onIconPickerSelected(fileData: fileData, output: self)
    }
    
    // MARK: - LocalObjectIconPickerOutput

    func localFileDataDidChanged(_ data: FileData?) {
        fileData = data
        let isCircular = self.data.channelType == nil && self.data.spaceUxType.isChat
        if let path = fileData?.path {
            spaceIcon = .object(.space(.localPath(path, circular: isCircular)))
        } else {
            spaceIcon = .object(.space(.name(name: spaceName, iconOption: spaceIconOption, circular: isCircular)))
        }
    }

    // MARK: - Private

    private func createChannel(channelType: ChannelType) async throws -> String {
        let accessType: SpaceAccessType = channelType == .personal ? .private : .shared

        let createResponse = try await workspaceService.createSpace(
            name: spaceName,
            iconOption: spaceIconOption,
            accessType: accessType,
            useCase: .none,
            withChat: false,
            uxType: .data
        )

        let spaceId = createResponse.spaceID

        if channelType == .group {
            let pendingIdentities = data.selectedContacts.map {
                PendingIdentity(identity: $0.identity, name: $0.name, globalName: $0.globalName, icon: $0.icon)
            }
            await pendingShareService.savePendingAndRunChain(spaceId: spaceId, identities: pendingIdentities)
        }

        return spaceId
    }

    private func createLegacySpace() async throws -> String {
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

        if uxType.isChat {
            do {
                _ = try await workspaceService.makeSharable(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
            } catch {}
        }

        return spaceId
    }
}
