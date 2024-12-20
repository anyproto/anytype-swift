import Foundation
import Combine
import AnytypeCore
import Services

// Used in SpaceSetupManager
@MainActor
protocol ActiveSpaceSetterProtocol: AnyObject, Sendable {
    func setActiveSpace(spaceId: String?) async throws
}

// Storage for store active space id for each screen.
@MainActor
protocol ActiveSpaceManagerProtocol: AnyObject, ActiveSpaceSetterProtocol {
    var workspaceInfo: AccountInfo? { get }
    var workspaceInfoPublisher: AnyPublisher<AccountInfo?, Never> { get }
    func startSubscription()
}

@MainActor
final class ActiveSpaceManager: ActiveSpaceManagerProtocol {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    // MARK: - State
    private var workspaceSubscription: AnyCancellable?
    private var activeSpaceId: String?
    lazy var workspaceInfoSubject = CurrentValueSubject<AccountInfo?, Never>(nil)
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    nonisolated init() {}
    
    var workspaceInfo: AccountInfo? {
        workspaceInfoSubject.value
    }
    
    var workspaceInfoPublisher: AnyPublisher<AccountInfo?, Never> {
        return workspaceInfoSubject.removeDuplicates().filter { $0 != .empty }.eraseToAnyPublisher()
    }
    
    func setActiveSpace(spaceId: String?) async throws {
        guard activeSpaceId != spaceId else { return }
        
        guard let spaceId else {
            workspaceInfoSubject.send(nil)
            activeSpaceId = nil
            await objectTypeProvider.stopSubscription(cleanCache: false)
            await relationDetailsStorage.stopSubscription(cleanCache: false)
            return
        }
        
        let info = try await workspaceService.workspaceOpen(spaceId: spaceId, withChat: FeatureFlags.homeSpaceLevelChat)
        workspaceStorage.addWorkspaceInfo(spaceId: spaceId, info: info)
        await objectTypeProvider.startSubscription(spaceId: spaceId)
        await relationDetailsStorage.startSubscription(spaceId: spaceId)
        
        logSwitchSpace(spaceId: spaceId)
        
        workspaceInfoSubject.send(info)
        activeSpaceId = spaceId
    }
    
    func startSubscription() {
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
    
    // MARK: - Private
    
    private func handleSpaces(spaceIds: [String]) async {
        guard let activeSpaceId, spaceIds.contains(activeSpaceId) else {
            try? await setActiveSpace(spaceId: nil)
            return
        }
    }
    
    private var latestNonNilSpaceId: String?
    private func logSwitchSpace(spaceId: String?) {
        guard spaceId.isNotNil else { return }
        guard latestNonNilSpaceId.isNotNil else {
            latestNonNilSpaceId = spaceId
            return
        }
        
        if latestNonNilSpaceId != spaceId {
            latestNonNilSpaceId = spaceId
            AnytypeAnalytics.instance().logSwitchSpace()
        }
    }
}

extension Container {
    
    // Instance for each scene
    
    var activeSpaceManager: Factory<any ActiveSpaceManagerProtocol> {
        self { ActiveSpaceManager() }
    }
}
