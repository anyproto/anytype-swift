import Foundation
import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
final class RemoteStorageViewModel: ObservableObject {
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    
    private let spaceId: String
    private weak var output: (any RemoteStorageModuleOutput)?
    private var subscriptions = [AnyCancellable]()
    private let subSpaceId = "RemoteStorageViewModel-Space-\(UUID())"
    
    private let segmentInfoBuilder = SegmentInfoBuilder()
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    private var nodeUsage: NodeUsageInfo?
    private var isLocalOnlyMode: Bool = false
    
    @Published var spaceInstruction: String = ""
    @Published var spaceUsed: String = ""
    @Published var contentLoaded: Bool = false
    @Published var showGetMoreSpaceButton: Bool = false
    @Published var membershipUpgradeReason: MembershipUpgradeReason?
    @Published var segmentInfo = RemoteStorageSegmentInfo()
    
    init(spaceId: String, output: (any RemoteStorageModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        
        setupPlaceholderState()
        checkLocalOnlyMode()
        Task { await setupSubscription() }
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
    
    private func setupSubscription() async {
        guard !isLocalOnlyMode else { return }
        
        fileLimitsStorage.nodeUsage
            .receiveOnMain()
            .sink { [weak self] nodeUsage in
                // Some times middleware responds with big delay.
                // If middle upload a lot of files, read operation blocked.
                // May be fixed in feature.
                // Slack discussion https://anytypeio.slack.com/archives/C04QVG8V15K/p1684399017487419?thread_ts=1684244283.014759&cid=C04QVG8V15K
                self?.contentLoaded = true
                self?.nodeUsage = nodeUsage
                self?.updateView(nodeUsage: nodeUsage)
            }
            .store(in: &subscriptions)
    }
    
    private func setupPlaceholderState() {
        updateView(nodeUsage: .placeholder)
    }
    
    private func updateView(nodeUsage: NodeUsageInfo) {
        let bytesUsed = nodeUsage.node.bytesUsage
        let bytesLimit = nodeUsage.node.bytesLimit
        
        let used = byteCountFormatter.string(fromByteCount: bytesUsed)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)
        
        spaceInstruction = Loc.FileStorage.Space.instruction(limit)
        spaceUsed = Loc.FileStorage.Space.used(used, limit)
        let percentUsage = Double(bytesUsed) / Double(bytesLimit)
        let percentToShowGetMoreButton = 0.7
        showGetMoreSpaceButton = percentUsage >= percentToShowGetMoreButton
        
        self.segmentInfo = segmentInfoBuilder.build(spaceId: spaceId, nodeUsage: nodeUsage)
    }
}
