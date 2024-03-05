import Foundation
import Combine
import AnytypeCore
import Services

// Storage for store active space id for each screen.
@MainActor
protocol ActiveWorkpaceStorageProtocol: AnyObject {
    var workspaceInfo: AccountInfo { get }
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> { get }
    func setActiveSpace(spaceId: String) async throws
    func setupActiveSpace() async
    func spaceView() -> SpaceView?
    func clearActiveSpace() async
}

@MainActor
final class ActiveWorkspaceStorage: ActiveWorkpaceStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    // MARK: - State
    private var workspaceSubscription: AnyCancellable?
    @UserDefault("activeSpaceId", defaultValue: "")
    private var activeSpaceId: String
    lazy var workspaceInfoSubject = CurrentValueSubject<AccountInfo, Never>(accountManager.account.info)
    
    nonisolated init() {}
    
    var workspaceInfo: AccountInfo {
        workspaceInfoSubject.value
    }
    
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> {
        return workspaceInfoSubject.removeDuplicates().filter { $0 != .empty }.eraseToAnyPublisher()
    }
    
    func setActiveSpace(spaceId: String) async throws {
        guard activeSpaceId != spaceId else { return }
        let info = try await workspaceService.workspaceOpen(spaceId: spaceId)
        AnytypeAnalytics.instance().logSwitchSpace()
        workspaceInfoSubject.send(info)
        activeSpaceId = spaceId
    }
    
    func setupActiveSpace() async {
        do {
            if activeSpaceId.isEmpty {
                activeSpaceId = accountManager.account.info.accountSpaceId
            }
            let info = try await workspaceService.workspaceOpen(spaceId: activeSpaceId)
            workspaceInfoSubject.send(info)
        } catch {
            await resetActiveSpace()
        }
        startSubscriotion()
    }
    
    func spaceView() -> SpaceView? {
        return workspaceStorage.spaceView(spaceViewId: workspaceInfo.spaceViewId)
    }
    
    func clearActiveSpace() async {
        activeSpaceId = ""
        workspaceInfoSubject.send(.empty)
        workspaceSubscription?.cancel()
    }
    
    // MARK: - Private
    
    private func startSubscriotion() {
        workspaceSubscription = workspaceStorage.workspsacesPublisher
            .map { $0.map(\.targetSpaceId) }
            .receiveOnMain()
            .sink { [weak self] spaceIds in
                guard let self else { return }
                Task {
                    await self.handleSpaces(spaceIds: spaceIds)
                }
            }
    }
    
    private func handleSpaces(spaceIds: [String]) async {
        if !spaceIds.contains(activeSpaceId) {
            await resetActiveSpace()
        }
    }
    
    private func resetActiveSpace() async {
        UserDefaultsConfig.lastOpenedPage = nil
        try? await setActiveSpace(spaceId: accountManager.account.info.accountSpaceId)
    }
}
