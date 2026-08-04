import Foundation
import Services
import AnytypeCore

struct VirtualTrailingBlockMaterialization {
    let info: BlockInformation
    /// True for the call that actually created the block, i.e. whose content was carried inside
    /// the BlockCreate request. Concurrent callers get `false` and must sync their newer state
    /// to `info.id` themselves.
    let contentCarried: Bool
}

/// One activation of the trailing "tap to type" placeholder.
///
/// The placeholder renders the standard text block UI over a locally fabricated
/// `BlockInformation` carrying a client-minted id — the same id the block keeps once it is
/// real. The block reaches the middleware only on first input, when `materialize` sends a
/// single BlockCreate already carrying that input and the minted id. Because the id never
/// changes, the row's identity, its cell, and the keyboard input session all survive
/// materialization untouched.
@MainActor
protocol VirtualTrailingBlockSessionProtocol: AnyObject {
    var blockId: String { get }
    var isMaterialized: Bool { get }
    var isMaterializing: Bool { get }

    func materialize(carrying content: BlockText) async throws -> VirtualTrailingBlockMaterialization
    func dismiss()
    func dismissAndFocusPreviousBlock()
}

@MainActor
final class VirtualTrailingBlockSession: VirtualTrailingBlockSessionProtocol {
    private enum State {
        case active
        case materializing(Task<BlockInformation, any Error>)
        case materialized(BlockInformation)
    }

    /// The block's final, client-minted id — identical before and after materialization.
    let blockId: String

    private let document: any BaseDocumentProtocol
    private let cursorManager: EditorCursorManager
    /// The placeholder was dismissed without a block ever being created.
    private let onDismiss: () -> Void
    /// Backspace dismissal: the row goes and the caret must continue in the previous text
    /// block. The editor moves first responder there *before* removing the row — removing
    /// the focused cell first briefly dismisses the keyboard.
    private let onDismissAndFocusPreviousBlock: () -> Void
    /// A BlockCreate attempt failed; the session is `.active` again. The editor decides
    /// whether the row stays (still editing — the next input retries) or goes.
    private let onMaterializationFailed: () -> Void

    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol

    private var state = State.active

    init(
        blockId: String,
        document: some BaseDocumentProtocol,
        cursorManager: EditorCursorManager,
        onDismiss: @escaping () -> Void,
        onDismissAndFocusPreviousBlock: @escaping () -> Void,
        onMaterializationFailed: @escaping () -> Void
    ) {
        self.blockId = blockId
        self.document = document
        self.cursorManager = cursorManager
        self.onDismiss = onDismiss
        self.onDismissAndFocusPreviousBlock = onDismissAndFocusPreviousBlock
        self.onMaterializationFailed = onMaterializationFailed
    }

    var isMaterialized: Bool {
        if case .materialized = state { return true }
        return false
    }

    var isMaterializing: Bool {
        if case .materializing = state { return true }
        return false
    }

    /// Called when the placeholder is torn down externally (e.g. the editor leaves editing
    /// mode). An in-flight creation still completes — the typed content must not be lost —
    /// but a pending focus for the placeholder must not fire afterwards.
    func invalidate() {
        if cursorManager.blockFocus?.id == blockId {
            cursorManager.blockFocus = nil
        }
    }

    func materialize(carrying content: BlockText) async throws -> VirtualTrailingBlockMaterialization {
        switch state {
        case let .materialized(info):
            return VirtualTrailingBlockMaterialization(info: info, contentCarried: false)
        case let .materializing(task):
            return VirtualTrailingBlockMaterialization(info: try await task.value, contentCarried: false)
        case .active:
            let task = Task { try await createBlock(carrying: content) }
            state = .materializing(task)
            do {
                let info = try await task.value
                state = .materialized(info)
                // Success needs no callback: the row already carries the created block's id
                // and the editor drops the session bookkeeping when the event lands.
                return VirtualTrailingBlockMaterialization(info: info, contentCarried: true)
            } catch {
                state = .active
                anytypeAssertionFailure("Trailing block materialization failed", info: ["error": error.localizedDescription])
                onMaterializationFailed()
                throw error
            }
        }
    }

    func dismiss() {
        guard case .active = state else { return }
        onDismiss()
    }

    func dismissAndFocusPreviousBlock() {
        guard case .active = state else { return }
        onDismissAndFocusPreviousBlock()
    }

    private func createBlock(carrying content: BlockText) async throws -> BlockInformation {
        let info = BlockInformation.empty(id: blockId, content: .text(content))
        AnytypeAnalytics.instance().logCreateBlock(type: info.content.type, spaceId: document.spaceId)
        let createdId = try await blockService.add(
            contextId: document.objectId,
            targetId: "",
            info: info,
            position: .bottom
        )
        if createdId != blockId {
            anytypeAssertionFailure(
                "BlockCreate did not echo the client-minted id",
                info: ["minted": blockId, "created": createdId]
            )
        }
        SessionCreatedBlockIdsStorage.shared.register(blockId)
        // The creation event may not be applied yet when the response returns; downstream
        // consumers (keyboard handler, the handler's own info) need id, parentId and the
        // carried content.
        return BlockInformation(
            id: blockId,
            content: .text(content),
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(parentId: document.objectId, backgroundColor: .default),
            fields: [:]
        )
    }
}
