import Foundation
import Factory
import Services

protocol PendingShareRetryServiceProtocol: AnyObject, Sendable {
    func retryIfNeeded(spaceId: String) async
}

final class PendingShareRetryService: PendingShareRetryServiceProtocol, @unchecked Sendable {

    @Injected(\.pendingShareStorage)
    private var storage: any PendingShareStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol

    func retryIfNeeded(spaceId: String) async {
        guard let pending = storage.pendingState(for: spaceId) else { return }

        var state = pending

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
