import Foundation
import Services

@MainActor
protocol WidgetsObjectsStorageProtocol: AnyObject, Sendable {
    func prepare(info: AccountInfo)
    func waitForReady(spaceId: String) async
    func widgetsObjects(spaceId: String) -> (channel: any BaseDocumentProtocol, personal: any BaseDocumentProtocol)?
}

@MainActor
final class WidgetsObjectsStorage: WidgetsObjectsStorageProtocol {

    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol

    private var currentSpaceId: String?
    private var channelDoc: (any BaseDocumentProtocol)?
    private var personalDoc: (any BaseDocumentProtocol)?
    private var openTask: Task<Void, Never>?

    nonisolated init() {}

    func prepare(info: AccountInfo) {
        if info.accountSpaceId == currentSpaceId, openTask != nil {
            return
        }

        // Releasing strong refs to old docs is what lets BaseDocument.deinit fire and
        // call middleware close(): DocumentsProvider.documentCache is strongToWeakObjects().
        openTask?.cancel()
        currentSpaceId = info.accountSpaceId

        let channel = documentsProvider.document(
            objectId: info.widgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )
        let personal = documentsProvider.document(
            objectId: info.personalWidgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )
        channelDoc = channel
        personalDoc = personal

        // Don't reset openTask in the body — a switch A→B that races with A's tail
        // would clobber B's task. A completed Task still resolves waitForReady via .value.
        openTask = Task {
            // `async let` starts personal.open() concurrently with channel.open() so the
            // two opens overlap instead of running sequentially. The trailing await on
            // `personalOpen` keeps the Task body alive until personal also finishes, so
            // waitForReady doesn't unblock callers while personal is still mid-open.
            async let personalOpen: Void? = try? await personal.open()
            try? await channel.open()
            _ = await personalOpen
        }
    }

    func waitForReady(spaceId: String) async {
        guard currentSpaceId == spaceId, let task = openTask else { return }
        await task.value
    }

    func widgetsObjects(spaceId: String) -> (channel: any BaseDocumentProtocol, personal: any BaseDocumentProtocol)? {
        guard currentSpaceId == spaceId, let channelDoc, let personalDoc else { return nil }
        return (channelDoc, personalDoc)
    }
}
