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
            do {
                let identityIds = state.identities.map(\.identity)
                try await workspaceService.participantsAdd(spaceId: spaceId, identities: identityIds)
            } catch {
                return
            }
        }

        storage.removePendingState(for: spaceId)
    }
}
