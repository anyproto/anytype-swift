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
        guard let pending = storage.pendingState(for: spaceId) else {
            debugPrint("==DEBUG retry: no pending state for \(spaceId)")
            return
        }

        debugPrint("==DEBUG retry: pending state found. makeShareable=\(pending.needsMakeShareable) generateInvite=\(pending.needsGenerateInvite) identities=\(pending.identities.count)")

        var state = pending

        if state.needsMakeShareable {
            do {
                debugPrint("==DEBUG retry: calling makeSharable")
                try await workspaceService.makeSharable(spaceId: spaceId)
                state.needsMakeShareable = false
                storage.savePendingState(state)
                debugPrint("==DEBUG retry: makeSharable success")
            } catch {
                debugPrint("==DEBUG retry: makeSharable FAILED: \(error)")
                return
            }
        }

        if state.needsGenerateInvite {
            do {
                debugPrint("==DEBUG retry: calling generateInvite")
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
                state.needsGenerateInvite = false
                storage.savePendingState(state)
                debugPrint("==DEBUG retry: generateInvite success")
            } catch {
                debugPrint("==DEBUG retry: generateInvite FAILED: \(error)")
                return
            }
        }

        if state.identities.isNotEmpty {
            do {
                let identityIds = state.identities.map(\.identity)
                debugPrint("==DEBUG retry: calling participantsAdd with \(identityIds.count) identities")
                try await workspaceService.participantsAdd(spaceId: spaceId, identities: identityIds)
                debugPrint("==DEBUG retry: participantsAdd success")
            } catch {
                debugPrint("==DEBUG retry: participantsAdd FAILED: \(error)")
                return
            }
        }

        storage.removePendingState(for: spaceId)
        debugPrint("==DEBUG retry: all steps complete, pending removed")
    }
}
