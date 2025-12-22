import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
@Observable
final class RemoteStorageViewModel {
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    @ObservationIgnored @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol

    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private weak var output: (any RemoteStorageModuleOutput)?
    @ObservationIgnored
    private let subSpaceId = "RemoteStorageViewModel-Space-\(UUID())"

    @ObservationIgnored
    private let segmentInfoBuilder = SegmentInfoBuilder()
    @ObservationIgnored
    private let byteCountFormatter = ByteCountFormatter.fileFormatter

    @ObservationIgnored
    private var nodeUsage: NodeUsageInfo?
    @ObservationIgnored
    private var isLocalOnlyMode: Bool = false

    var spaceInstruction: String = ""
    var spaceUsed: String = ""
    var contentLoaded: Bool = false
    var showGetMoreSpaceButton: Bool = false
    var membershipUpgradeReason: MembershipUpgradeReason?
    var segmentInfo = RemoteStorageSegmentInfo()

    init(spaceId: String, output: (any RemoteStorageModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output

        setupPlaceholderState()
        checkLocalOnlyMode()
    }
        
    func onTapManageFiles() {
        output?.onManageFilesSelected()
    }
    
    func onAppear() {
        // TODO: Add analytics
    }
    
    func onTapGetMoreSpace() {
        AnytypeAnalytics.instance().logClickUpgradePlanTooltip(type: .storage, route: .remoteStorage)
        membershipUpgradeReason = .storageSpace
    }
    
    // MARK: - Private
    private func checkLocalOnlyMode() {
        isLocalOnlyMode = serverConfigurationStorage.currentConfiguration().isLocalOnly
        if isLocalOnlyMode {
            setupLocalOnlyState()
        }
    }

    private func setupLocalOnlyState() {
        spaceInstruction = Loc.FileStorage.Space.localOnlyInstruction
        contentLoaded = true
        showGetMoreSpaceButton = false
    }

    func startSubscription() async {
        guard !isLocalOnlyMode else { return }

        // Some times middleware responds with big delay.
        // If middle upload a lot of files, read operation blocked.
        // May be fixed in feature.
        // Slack discussion https://anytypeio.slack.com/archives/C04QVG8V15K/p1684399017487419?thread_ts=1684244283.014759&cid=C04QVG8V15K
        for await nodeUsage in fileLimitsStorage.nodeUsage.values {
            contentLoaded = true
            self.nodeUsage = nodeUsage
            updateView(nodeUsage: nodeUsage)
        }
    }
    
    private func setupPlaceholderState() {
        updateView(nodeUsage: .placeholder)
    }
    
    private func updateView(nodeUsage: NodeUsageInfo) {
        let bytesUsed = nodeUsage.node.bytesUsage
        let bytesLimit = nodeUsage.node.bytesLimit

        let used = byteCountFormatter.string(fromByteCount: bytesUsed)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)

        spaceInstruction = Loc.FileStorage.Space.instruction
        spaceUsed = Loc.FileStorage.Space.used(used, limit)
        let percentUsage = Double(bytesUsed) / Double(bytesLimit)
        let percentToShowGetMoreButton = 0.7
        showGetMoreSpaceButton = percentUsage >= percentToShowGetMoreButton
        
        self.segmentInfo = segmentInfoBuilder.build(spaceId: spaceId, nodeUsage: nodeUsage)
    }
}
