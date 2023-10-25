import Foundation
import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
final class RemoteStorageViewModel: ObservableObject {
    
    private enum Constants {
        
        static let warningPercent = 0.9
        static let mailTo = "storage@anytype.io"
    }
    
    private let accountManager: AccountManagerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let fileLimitsStorage: FileLimitsStorageProtocol
    private let documentProvider: DocumentsProviderProtocol
    private weak var output: RemoteStorageModuleOutput?
    private var subscriptions = [AnyCancellable]()
    private let subSpaceId = "RemoteStorageViewModel-Space-\(UUID())"
    
    private let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .binary
        formatter.allowsNonnumericFormatting = false
        return formatter
    }()
    
    private var limits: FileLimits?
    
    @Published var spaceInstruction: String = ""
    @Published var spaceName: String = ""
    @Published var percentUsage: Double = 0
    @Published var spaceIcon: Icon?
    @Published var spaceUsed: String = ""
    @Published var spaceUsedWarning: Bool = false
    @Published var contentLoaded: Bool = false
    @Published var showGetMoreSpaceButton: Bool = false
    let progressBarConfiguration = LineProgressBarConfiguration.fileStorage
    
    init(
        accountManager: AccountManagerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        fileLimitsStorage: FileLimitsStorageProtocol,
        documentProvider: DocumentsProviderProtocol,
        output: RemoteStorageModuleOutput?
    ) {
        self.accountManager = accountManager
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.fileLimitsStorage = fileLimitsStorage
        self.documentProvider = documentProvider
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
        guard let limits else { return }
        AnytypeAnalytics.instance().logGetMoreSpace()
        Task { @MainActor in
            let profileDocument = documentProvider.document(
                objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID,
                forPreview: true
            )
            try await profileDocument.openForPreview()
            let limit = byteCountFormatter.string(fromByteCount: limits.bytesLimit)
            let mailLink = MailUrl(
                to: Constants.mailTo,
                subject: Loc.FileStorage.Space.Mail.subject(accountManager.account.id),
                body: Loc.FileStorage.Space.Mail.body(limit, accountManager.account.id, profileDocument.details?.name ?? "")
            )
            guard let mailLinkUrl = mailLink.url else { return }
            output?.onLinkOpen(url: mailLinkUrl)
        }
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        fileLimitsStorage.setupSpaceId(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId)
        fileLimitsStorage.limits
            .receiveOnMain()
            .sink { [weak self] limits in
                // Some times middleware responds with big delay.
                // If middle upload a lot of files, read operation blocked.
                // May be fixed in feature.
                // Slack discussion https://anytypeio.slack.com/archives/C04QVG8V15K/p1684399017487419?thread_ts=1684244283.014759&cid=C04QVG8V15K
                self?.contentLoaded = true
                self?.limits = limits
                self?.updateView(limits: limits)
            }
            .store(in: &subscriptions)
            
        
        await subscriptionService.startSubscription(
            subId: subSpaceId,
            objectId: activeWorkspaceStorage.workspaceInfo.spaceViewId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
    }
    
    private func setupPlaceholderState() {
        handleSpaceDetails(details: ObjectDetails(id: ""))
        updateView(limits: .zero)
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceIcon = details.objectIconImage
        spaceName = details.name.isNotEmpty ? details.name : Loc.Object.Title.placeholder
    }
    
    private func updateView(limits: FileLimits) {
        let bytesUsed = limits.bytesUsage
        let bytesLimit = limits.bytesLimit
        let localBytesUsage = limits.localBytesUsage
        
        let used = byteCountFormatter.string(fromByteCount: bytesUsed)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)
        
        spaceInstruction = Loc.FileStorage.Space.instruction(limit)
        spaceUsed = Loc.FileStorage.Space.used(used, limit)
        percentUsage = Double(bytesUsed) / Double(bytesLimit)
        spaceUsedWarning = percentUsage >= Constants.warningPercent
        let localPercentUsage = Double(localBytesUsage) / Double(bytesLimit)
        showGetMoreSpaceButton = percentUsage >= Constants.warningPercent || localPercentUsage >= Constants.warningPercent
    }
}
