import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
@Observable
final class FileStorageViewModel {

    @ObservationIgnored @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol

    @ObservationIgnored
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    @ObservationIgnored
    private var nodeUsage: NodeUsageInfo?

    let phoneName: String = UIDevice.current.name
    var locaUsed: String = ""
    var contentLoaded: Bool = false
    var showClearCacheAlert = false

    init() {
        setupPlaceholderState()
    }
    
    func onTapOffloadFiles() {
        showClearCacheAlert = true
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsStorageIndex()
    }

    // MARK: - Private

    func startSubscription() async {
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
        let localBytesUsage = nodeUsage.node.localBytesUsage
        let local = byteCountFormatter.string(fromByteCount: localBytesUsage)
        locaUsed = Loc.FileStorage.Local.used(local)
    }
}
