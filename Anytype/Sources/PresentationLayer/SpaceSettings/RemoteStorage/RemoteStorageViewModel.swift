import Foundation
import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
final class RemoteStorageViewModel: ObservableObject {
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    
    private let spaceId: String
    private weak var output: (any RemoteStorageModuleOutput)?
    private var subscriptions = [AnyCancellable]()
    private let subSpaceId = "RemoteStorageViewModel-Space-\(UUID())"
    
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    private var nodeUsage: NodeUsageInfo?
    
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
        Task {
            await setupSubscription()
        }
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
    private func setupSubscription() async {
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
        
        var segmentInfo = RemoteStorageSegmentInfo()
        
        if let spaceView = workspaceStorage.spaceView(spaceId: spaceId) {
            let spaceBytesUsage = nodeUsage.spaces.first(where: { $0.spaceID == spaceId })?.bytesUsage ?? 0
            segmentInfo.currentUsage = Double(spaceBytesUsage) / Double(bytesLimit)
            segmentInfo.currentLegend = Loc.FileStorage.LimitLegend.current(spaceView.title, byteCountFormatter.string(fromByteCount: spaceBytesUsage))
        }
       
        let otherSpaces = participantSpacesStorage.activeParticipantSpaces
            .filter(\.isOwner)
            .map(\.spaceView)
            .filter { $0.targetSpaceId != spaceId }
        
        if otherSpaces.isNotEmpty {
            segmentInfo.otherUsages = otherSpaces.map { spaceView in
                let spaceBytesUsage = nodeUsage.spaces.first(where: { $0.spaceID == spaceView.targetSpaceId })?.bytesUsage ?? 0
                return  Double(spaceBytesUsage) / Double(bytesLimit)
            }
            
            let otherUsageBytes = nodeUsage.spaces.filter { $0.spaceID != spaceId }.reduce(Int64(0), { $0 + $1.bytesUsage })
            segmentInfo.otherLegend = Loc.FileStorage.LimitLegend.other(byteCountFormatter.string(fromByteCount: otherUsageBytes))
        }
        
        segmentInfo.free = Double(nodeUsage.node.bytesLeft) / Double(bytesLimit)
        segmentInfo.freeLegend = Loc.FileStorage.LimitLegend.free(byteCountFormatter.string(fromByteCount: nodeUsage.node.bytesLeft))
        
        self.segmentInfo = segmentInfo
    }
}
