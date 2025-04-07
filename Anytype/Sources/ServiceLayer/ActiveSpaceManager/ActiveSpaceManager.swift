import Foundation
import AnytypeCore
import Services
import AsyncTools

protocol ActiveSpaceManagerProtocol: AnyObject, Sendable {
    var workspaceInfoStream: AnyAsyncSequence<AccountInfo> { get }
    func setActiveSpace(spaceId: String?) async throws
    func startSubscription() async
    func stopSubscription() async
}

actor ActiveSpaceManager: ActiveSpaceManagerProtocol, Sendable {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    // MARK: - State
    private var workspaceSubscription: Task<Void, Never>?
    private var activeSpaceId: String?
    private let workspaceInfoStreamInternal = AsyncToManyStream<AccountInfo?>()
    private var setActiveSpaceTask: Task<Void, any Error>?
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    init() {}
    
    nonisolated var workspaceInfoStream: AnyAsyncSequence<AccountInfo> {
        AsyncStream.task { iterator in
            for await info in workspaceInfoStreamInternal {
                if let info {
                    iterator(info)
                }
            }
        }.eraseToAnyAsyncSequence()
    }
    
    func setActiveSpace(spaceId: String?) async throws {
        if activeSpaceId == spaceId {
            try await setActiveSpaceTask?.value
            return
        }
        
        activeSpaceId = spaceId
        setActiveSpaceTask?.cancel()
        
        setActiveSpaceTask = Task {
            if let spaceId {
                do {
                    let info = try await workspaceService.workspaceOpen(spaceId: spaceId, withChat: FeatureFlags.homeSpaceLevelChat)
                    workspaceStorage.addWorkspaceInfo(spaceId: spaceId, info: info)
                    await objectTypeProvider.startSubscription(spaceId: spaceId)
                    await relationDetailsStorage.startSubscription(spaceId: spaceId)
                    
                    logSwitchSpace(spaceId: spaceId)
                    
                    workspaceInfoStreamInternal.send(info)
                } catch {
                    // Reset active space for try open again in next time
                    await clearActiveSpace()
                    throw error
                }
            } else {
                await clearActiveSpace()
            }
        }
        
        try await setActiveSpaceTask?.value
        return
    }
    
    func startSubscription() {
        workspaceSubscription = Task { [weak self, workspaceStorage] in
            for await workspaces in workspaceStorage.activeWorkspsacesPublisher.values {
                let spaceIds = workspaces.map(\.targetSpaceId)
                await self?.handleSpaces(spaceIds: spaceIds)
            }
        }
    }
    
    func stopSubscription() {
        workspaceSubscription?.cancel()
        workspaceSubscription = nil
        activeSpaceId = nil
        workspaceInfoStreamInternal.send(nil)
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
    
    private func clearActiveSpace() async {
        workspaceInfoStreamInternal.send(nil)
        activeSpaceId = nil
        await objectTypeProvider.stopSubscription(cleanCache: false)
        await relationDetailsStorage.stopSubscription(cleanCache: false)
    }
}
