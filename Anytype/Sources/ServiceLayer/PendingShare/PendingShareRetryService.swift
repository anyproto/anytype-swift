import Foundation
import Factory
import Services
import ProtobufMessages

protocol PendingShareServiceProtocol: AnyObject, Sendable {
    func savePendingAndRunChain(spaceId: String, identities: [PendingIdentity]) async
    func retryIfNeeded(spaceId: String) async
}

actor PendingShareService: PendingShareServiceProtocol {

    @Injected(\.pendingShareStorage)
    private var storage: any PendingShareStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    private var runningSpaceIds = Set<String>()

    func savePendingAndRunChain(spaceId: String, identities: [PendingIdentity]) {
        storage.savePendingState(PendingShareState(
            spaceId: spaceId,
            identities: identities,
            needsMakeShareable: true,
            needsGenerateInvite: true
        ))

        Task { await runChain(spaceId: spaceId) }
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
            // Members are added to the ACL directly; the invite only has to exist. Keep the owner's
            // invite untouched and default new ones to request-to-join, held by the owner.
            do {
                _ = try await workspaceService.getCurrentInvite(spaceId: spaceId)
            } catch let error as Anytype_Rpc.Space.InviteGetCurrent.Response.Error where error.code == .noActiveInvite {
                do {
                    _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .member, permissions: nil)
                } catch {
                    return
                }
            } catch {
                // Transient failure — retry the whole step later instead of risking a duplicate invite
                return
            }
            state.needsGenerateInvite = false
            storage.savePendingState(state)
        }

        // Middleware participantsAddList is idempotent — re-sending already-added participants is a no-op.
        // On retry, writers who were added before a partial failure will be safely skipped.
        if state.identities.isNotEmpty {
            let identityIds = state.identities.map(\.identity)
            let availableWriterSlots = participantSpacesStorage.participantSpaceView(spaceId: spaceId)?.spaceView.availableWriterSlots
                ?? participantSpacesStorage.allParticipantSpaces
                    .first { $0.spaceView.isActive && $0.spaceView.isShared && $0.isOwner }?
                    .spaceView.availableWriterSlots
                ?? 0

            let writerIds = Array(identityIds.prefix(availableWriterSlots))
            let readerIds = Array(identityIds.dropFirst(availableWriterSlots))

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
