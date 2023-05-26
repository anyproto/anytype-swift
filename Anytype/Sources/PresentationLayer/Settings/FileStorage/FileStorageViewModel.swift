import Foundation
import Services
import UIKit
import Combine

@MainActor
final class FileStorageViewModel: ObservableObject {
    
    private enum Constants {
        static let subSpaceId = "FileStorageSpace"
        static let warningPercent = 0.9
    }
    

    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let fileLimitsStorage: FileLimitsStorageProtocol
    private weak var output: FileStorageModuleOutput?
    private var subscriptions = [AnyCancellable]()
    
    private let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .binary
        return formatter
    }()
    
    @Published var spaceInstruction: String = ""
    @Published var spaceName: String = ""
    @Published var percentUsage: Double = 0
    @Published var spaceIcon: ObjectIconImage?
    @Published var spaceUsed: String = ""
    let phoneName: String = UIDevice.current.name
    @Published var locaUsed: String = ""
    @Published var spaceUsedWarning: Bool = false
    @Published var contentLoaded: Bool = false
    let progressBarConfiguration = LineProgressBarConfiguration.fileStorage
    
    init(
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        fileLimitsStorage: FileLimitsStorageProtocol,
        output: FileStorageModuleOutput?
    ) {
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.fileLimitsStorage = fileLimitsStorage
        self.output = output
        setupPlaceholderState()
        setupSubscription()
    }
    
    func onTapOffloadFiles() {
        output?.onClearCacheSelected()
    }
    
    func onTapManageFiles() {
        output?.onManageFilesSelected()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsStorageIndex()
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        
        fileLimitsStorage.limits
            .receiveOnMain()
            .sink { [weak self] limits in
                // Some times middleware responds with big delay.
                // If middle upload a lot of files, read operation blocked.
                // May be fixed in feature.
                // Slack discussion https://anytypeio.slack.com/archives/C04QVG8V15K/p1684399017487419?thread_ts=1684244283.014759&cid=C04QVG8V15K
                self?.contentLoaded = true
                self?.updateView(limits: limits)
            }
            .store(in: &subscriptions)
            
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.accountSpaceId
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
        spaceName = details.name.isNotEmpty ? details.name : Loc.untitled
    }
    
    private func updateView(limits: FileLimits) {
        let bytesUsed = limits.bytesUsage
        let bytesLimit = limits.bytesLimit
        let localBytesUsage = limits.localBytesUsage
        
        let used = byteCountFormatter.string(fromByteCount: bytesUsed)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)
        let local = byteCountFormatter.string(fromByteCount: localBytesUsage)
        
        spaceInstruction = Loc.FileStorage.Space.instruction(limit)
        spaceUsed = Loc.FileStorage.Space.used(used, limit)
        percentUsage = Double(bytesUsed) / Double(bytesLimit)
        locaUsed = Loc.FileStorage.Local.used(local)
        spaceUsedWarning = percentUsage >= Constants.warningPercent
    }
}
