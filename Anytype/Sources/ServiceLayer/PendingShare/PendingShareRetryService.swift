import Foundation
import Factory
import Services

protocol PendingShareServiceProtocol: AnyObject, Sendable {
    func savePendingAndRunChain(spaceId: String, identities: [PendingIdentity])
    func retryIfNeeded(spaceId: String) async
}

final class PendingShareService: PendingShareServiceProtocol, @unchecked Sendable {

    @Injected(\.pendingShareStorage)
    private var storage: any PendingShareStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    private var runningSpaceIds = Set<String>()

    func savePendingAndRunChain(spaceId: String, identities: [PendingIdentity]) {
        storage.savePendingState(PendingShareState(
            spaceId: spaceId,
            identities: identities,
            needsMakeShareable: true,
            needsGenerateInvite: true
        ))

        Task {
            await runChain(spaceId: spaceId)
        }
    }

    func retryIfNeeded(spaceId: String) async {
        guard storage.pendingState(for: spaceId) != nil else { return }
        await runChain(spaceId: spaceId)
    }

    // MARK: - Private

    private func runChain(spaceId: String) async {
        guard !runningSpaceIds.contains(spaceId) else { return }
        runningSpaceIds.insert(spaceId)
        defer { runningSpaceIds.remove(spaceId) }

        guard var state = storage.pendingState(for: spaceId) else { return }

        if state.needsMakeShareable {
            do {
                try await workspaceService.makeSharable(spaceId: spaceId)
                state.needsMakeShareable = false
                storage.savePendingState(state)
            } catch {
                return
            }
        }

        if state.needsGenerateInvite {
            do {
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
                state.needsGenerateInvite = false
                storage.savePendingState(state)
            } catch {
                return
            }
        }

        if state.identities.isNotEmpty {
            let identityIds = state.identities.map(\.identity)
            let writersLimit = spaceViewsStorage.spaceView(spaceId: spaceId)?.writersLimit ?? identityIds.count

            let writerIds = Array(identityIds.prefix(writersLimit))
            let readerIds = Array(identityIds.dropFirst(writersLimit))

            if writerIds.isNotEmpty {
                do {
                    try await workspaceService.participantsAdd(spaceId: spaceId, identities: writerIds, permissions: .writer)
                } catch {
                    return
                }
            }

            if readerIds.isNotEmpty {
                do {
                    try await workspaceService.participantsAdd(spaceId: spaceId, identities: readerIds, permissions: .reader)
                } catch {
                    return
                }
            }
        }

        storage.removePendingState(for: spaceId)
    }
}
