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
        self.spaceIcon = .object(.space(.name(name: "", iconOption: spaceIconOption, circular: false)))
        self.isConnected = networkStatusProvider.isConnected
    }

    func onTapCreate() async throws {
        let spaceId = try await createChannel(channelType: data.channelType)

        if let fileData {
            let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: fileData, origin: .none)
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AnytypeAnalytics.instance().logCreateSpace(spaceId: spaceId, spaceType: .regular, route: .navigation)
        if data.channelType == .group {
            AnytypeAnalytics.instance().logAddMember(count: data.selectedContacts.count)
        }
        try await output?.onSpaceCreated(spaceId: spaceId)
    }

    func onAppear() {
        isConnected = networkStatusProvider.isConnected
        AnytypeAnalytics.instance().logScreenSettingsSpaceCreate(status: isConnected ? .online : .offline)
    }

    func startNetworkObservation() async {
        for await connected in networkStatusProvider.isConnectedPublisher.values {
            isConnected = connected
        }
    }

    func updateNameIconIfNeeded(_ name: String) {
        guard fileData.isNil else { return }
        spaceIcon = .object(.space(.name(name: name, iconOption: spaceIconOption, circular: false)))
    }

    func onIconTapped() {
        output?.onIconPickerSelected(fileData: fileData, output: self)
    }

    // MARK: - LocalObjectIconPickerOutput

    func localFileDataDidChanged(_ data: FileData?) {
        fileData = data
        if let path = fileData?.path {
            spaceIcon = .object(.space(.localPath(path, circular: false)))
        } else {
            spaceIcon = .object(.space(.name(name: spaceName, iconOption: spaceIconOption, circular: false)))
        }
    }

    // MARK: - Private

    private func createChannel(channelType: ChannelType) async throws -> String {
        let accessType: SpaceAccessType = channelType == .personal ? .private : .shared

        let createResponse = try await workspaceService.createSpace(
            name: spaceName,
            iconOption: spaceIconOption,
            accessType: accessType,
            useCase: .dataSpaceMobile,
            withChat: false,
            spaceType: .regular
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
}
