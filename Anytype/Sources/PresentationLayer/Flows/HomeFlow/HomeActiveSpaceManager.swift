import Foundation
import Combine
import AnytypeCore
import Services

// TODO: Update with optional workspace info

// For other screens, for SpaceSetupManager
@MainActor
protocol HomeSpaceSetupManagerProtocol: AnyObject {
    func setActiveSpace(spaceId: String) async throws
}

// Storage for store active space id for each screen.
@MainActor
protocol HomeActiveSpaceManagerProtocol: AnyObject, HomeSpaceSetupManagerProtocol {
    var workspaceInfo: AccountInfo { get }
    var workspaceInfoPublisher: AnyPublisher<AccountInfo, Never> { get }
    func setupActiveSpace() async
}

@MainActor
final class HomeActiveSpaceManager: HomeActiveSpaceManagerProtocol {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
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
        workspaceStorage.addWorkspaceInfo(spaceId: spaceId, info: info)
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
            workspaceStorage.addWorkspaceInfo(spaceId: activeSpaceId, info: info)
            workspaceInfoSubject.send(info)
        } catch {
            await resetActiveSpace()
        }
        startSubscription()
    }
    
    // MARK: - Private
    
    private func startSubscription() {
        workspaceSubscription = workspaceStorage.activeWorkspsacesPublisher
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
        try? await setActiveSpace(spaceId: accountManager.account.info.accountSpaceId)
    }
}

extension Container {
    
    // Instance for each scene
    
    var homeActiveSpaceManager: Factory<any HomeActiveSpaceManagerProtocol> {
        self { HomeActiveSpaceManager() }
    }
}
