import Foundation
import BlocksModels
import UIKit

@MainActor
final class FileStorageViewModel: ObservableObject {
    
    private enum Constants {
        static let subSpaceId = "FileStorageSpace"
    }
    
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private weak var output: FileStorageModuleOutput?
    
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
    
    init(
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        output: FileStorageModuleOutput?
    ) {
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.output = output
        setupSubscription()
        mockBytes()
    }
    
    func onTapOffloadFiles() {
        output?.onClearCacheSelected()
    }
    
    func onTapManageFiles() {
        output?.onManageFilesSelected()
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.accountSpaceId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceIcon = details.objectIconImage
        spaceName = details.name.isNotEmpty ? details.name : Loc.untitled
    }
    
    private func mockBytes() {
        let bytesLeft: Int64 = 500 * 1024 * 1024
        let bytesLimit: Int64 = 1024 * 1024 * 1024
        let localBytesUsage: Int64 = 104 * 1024 * 1024
        
        let left = byteCountFormatter.string(fromByteCount: bytesLeft)
        let limit = byteCountFormatter.string(fromByteCount: bytesLimit)
        let local = byteCountFormatter.string(fromByteCount: localBytesUsage)
        
        spaceInstruction = Loc.FileStorage.Space.instruction(limit)
        spaceUsed = Loc.FileStorage.Space.used(left, limit)
        percentUsage = Double(bytesLeft) / Double(bytesLimit)
        locaUsed = Loc.FileStorage.Local.used(local)
    }
}
