import Foundation
import AnytypeCore
import Services
import AsyncTools

protocol ActiveSpaceManagerProtocol: AnyObject, Sendable {
    var workspaceInfoStream: AnyAsyncSequence<AccountInfo?> { get }
    var workspaceInfo: AccountInfo? { get }
    @discardableResult
    func setActiveSpace(spaceId: String?) async throws -> AccountInfo?
    func prepareSpaceForPreview(spaceId: String) async
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
    private var spaceIsLoading: Bool = false
    private let workspaceInfoStreamInternal = AsyncToManyStream<AccountInfo?>()
    private let workspaceInfoStorage = AtomicStorage<AccountInfo?>(nil)
    private var setActiveSpaceTask: Task<AccountInfo?, any Error>?
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    init() {}
    
    nonisolated var workspaceInfoStream: AnyAsyncSequence<AccountInfo?> {
        workspaceInfoStreamInternal.eraseToAnyAsyncSequence()
    }
    
    nonisolated var workspaceInfo: AccountInfo? {
        workspaceInfoStorage.value
    }
    
    @discardableResult
    func setActiveSpace(spaceId: String?) async throws -> AccountInfo? {
        if activeSpaceId == spaceId {
            return try await setActiveSpaceTask?.value
        }
        
        activeSpaceId = spaceId
        setActiveSpaceTask?.cancel()
        
        setActiveSpaceTask = Task {
            spaceIsLoading = true
            defer { spaceIsLoading = false }
            if let spaceId {
                do {
                    let info = try await workspaceService.workspaceOpen(spaceId: spaceId, withChat: true)
                    workspaceStorage.addWorkspaceInfo(spaceId: spaceId, info: info)
                    await objectTypeProvider.startSubscription(spaceId: spaceId)
                    await propertyDetailsStorage.startSubscription(spaceId: spaceId)
                    
                    logSwitchSpace(spaceId: spaceId)
                    
                    workspaceInfoStreamInternal.send(info)
                    workspaceInfoStorage.value = info
                    return info
                } catch {
                    // Reset active space for try open again in next time
                    await clearActiveSpace()
                    throw error
                }
            } else {
                await clearActiveSpace()
                return nil
            }
        }
        
        return try await setActiveSpaceTask?.value
    }
    
    func startSubscription() {
        workspaceSubscription = Task { [weak self, workspaceStorage] in
            for await workspaces in workspaceStorage.allWorkspsacesPublisher.values {
                await self?.handleSpaces(workspaces: workspaces)
            }
        }
    }
    
    func stopSubscription() {
        workspaceSubscription?.cancel()
        workspaceSubscription = nil
        activeSpaceId = nil
        workspaceInfoStreamInternal.send(nil)
        workspaceInfoStorage.value = nil
    }
    
    func prepareSpaceForPreview(spaceId: String) async {
        await objectTypeProvider.prepareData(spaceId: spaceId)
        await propertyDetailsStorage.prepareData(spaceId: spaceId)
    }
    
    // MARK: - Private
    
    private func handleSpaces(workspaces: [SpaceView]) async {
        if FeatureFlags.spaceLoadingForScreen {
            guard let activeSpaceId,
                  let currentView = workspaces.first(where: { $0.targetSpaceId == activeSpaceId }),
                  (currentView.isLoading && spaceIsLoading) || currentView.isActive else {
                _ = try? await setActiveSpace(spaceId: nil)
                return
            }
        } else {
            let spaceIds = workspaces.map(\.targetSpaceId)
            guard let activeSpaceId, spaceIds.contains(activeSpaceId) else {
                _ = try? await setActiveSpace(spaceId: nil)
                return
            }
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
        workspaceInfoStorage.value = nil
        activeSpaceId = nil
        await objectTypeProvider.stopSubscription()
        await propertyDetailsStorage.stopSubscription()
    }
}
