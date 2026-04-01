import Foundation
import Factory
import Services

@MainActor
protocol PendingShareServiceProtocol: AnyObject {
    func savePendingAndRunChain(spaceId: String, identities: [PendingIdentity])
    func retryIfNeeded(spaceId: String) async
}

@MainActor
final class PendingShareService: PendingShareServiceProtocol {

    @Injected(\.pendingShareStorage)
    private var storage: any PendingShareStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol

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
            let writers = state.identities.filter { $0.role == .writer }.map(\.identity)
            let readers = state.identities.filter { $0.role == .reader }.map(\.identity)

            if writers.isNotEmpty {
                do {
                    try await workspaceService.participantsAdd(spaceId: spaceId, identities: writers, permissions: .writer)
                } catch {
                    return
                }
            }

            if readers.isNotEmpty {
                do {
                    try await workspaceService.participantsAdd(spaceId: spaceId, identities: readers, permissions: .reader)
                } catch {
                    return
                }
            }
        }

        storage.removePendingState(for: spaceId)
    }
}
