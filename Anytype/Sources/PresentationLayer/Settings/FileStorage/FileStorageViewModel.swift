import Foundation
import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
final class FileStorageViewModel: ObservableObject {
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let fileLimitsStorage: FileLimitsStorageProtocol
    private let documentsProvider: DocumentsProviderProtocol
    private weak var output: FileStorageModuleOutput?
    private var subscriptions = [AnyCancellable]()
    
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    private var limits: FileLimits?
    private let subSpaceId = "FileStorageSpace-\(UUID().uuidString)"
    
    let phoneName: String = UIDevice.current.name
    @Published var locaUsed: String = ""
    @Published var contentLoaded: Bool = false
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        fileLimitsStorage: FileLimitsStorageProtocol,
        documentsProvider: DocumentsProviderProtocol,
        output: FileStorageModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.fileLimitsStorage = fileLimitsStorage
        self.documentsProvider = documentsProvider
        self.output = output
        setupPlaceholderState()
        Task {
            await setupSubscription()
        }
    }
    
    func onTapOffloadFiles() {
        output?.onClearCacheSelected()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsStorageIndex()
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
    }
    
    private func setupPlaceholderState() {
        updateView(limits: .zero)
    }
    
    private func updateView(limits: FileLimits) {
        let localBytesUsage = limits.localBytesUsage
        let local = byteCountFormatter.string(fromByteCount: localBytesUsage)
        locaUsed = Loc.FileStorage.Local.used(local)
    }
}
