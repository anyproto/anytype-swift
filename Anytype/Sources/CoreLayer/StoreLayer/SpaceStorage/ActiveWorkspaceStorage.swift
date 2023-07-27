import Foundation
import Combine
import AnytypeCore
import Services

// Storage for store active space id for each screen.
protocol ActiveWorkpaceStorageProtocol: AnyObject {
    var workspaceInfo: AccountInfo { get }
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> { get }
    func setActiveSpace(spaceId: String) async throws
}

final class ActiveWorkspaceStorage: ActiveWorkpaceStorageProtocol {
    
    // MARK: - DI
    
    private let workspaceStorage: WorkspacesStorageProtocol
    private let accountManager: AccountManagerProtocol
    private let workspaceService: WorkspaceServiceProtocol
    
    // MARK: - State
    
    private var workspaceSubscription: AnyCancellable?
    @UserDefault("activeSpaceId", defaultValue: "")
    private var activeSpaceId: String
    @Published
    private(set) var workspaceInfo: AccountInfo
    
    init(workspaceStorage: WorkspacesStorageProtocol, accountManager: AccountManagerProtocol, workspaceService: WorkspaceServiceProtocol) {
        // TODO: Handle deleted workpace
        self.workspaceStorage = workspaceStorage
        self.accountManager = accountManager
        self.workspaceService = workspaceService
        self.workspaceInfo = accountManager.account.info
        Task {
            await setupActiveSpace()
        }
    }
    
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> {
        return $workspaceInfo.removeDuplicates().eraseToAnyPublisher()
    }
    
    func setActiveSpace(spaceId: String) async throws {
        let info = try await workspaceService.workspaceInfo(spaceId: spaceId)
        workspaceInfo = info
        activeSpaceId = spaceId
    }
    
    // MARK: - Private
    
    private func setupActiveSpace() async {
        do {
            let info = try await workspaceService.workspaceInfo(spaceId: activeSpaceId)
            workspaceInfo = info
        } catch {
            resetActiveSpace()
        }
        startSubscriotion()
    }
    
    private func startSubscriotion() {
        workspaceSubscription = workspaceStorage.workspsacesPublisher
            .map { $0.map(\.spaceId) }
            .receiveOnMain()
            .sink { [weak self] spaceIds in
                guard let self else { return }
                if !spaceIds.contains(activeSpaceId) {
                    resetActiveSpace()
                }
            }
    }
    
    private func resetActiveSpace() {
        workspaceInfo = accountManager.account.info
        activeSpaceId = workspaceInfo.accountSpaceId
    }
}
