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
/// `BlockInformation` that never reaches the middleware. The block becomes real only on first
/// input, when `materialize` sends a single BlockCreate already carrying that input.
@MainActor
protocol VirtualTrailingBlockSessionProtocol: AnyObject {
    var virtualId: String { get }
    var isMaterialized: Bool { get }
    var isMaterializing: Bool { get }

    func materialize(carrying content: BlockText, focusAt: BlockFocusPosition?) async throws -> VirtualTrailingBlockMaterialization
    func dismiss()
    func dismissAndFocusPreviousBlock()
    func completeFocusHandoff()
}

@MainActor
final class VirtualTrailingBlockSession: VirtualTrailingBlockSessionProtocol {
    private enum State {
        case active
        case materializing(Task<BlockInformation, any Error>)
        case materialized(BlockInformation)
    }

    let virtualId: String

    private let document: any BaseDocumentProtocol
    private let cursorManager: EditorCursorManager
    private let modelsHolder: EditorMainItemModelsHolder
    private let collectionController: EditorBlockCollectionController
    private let onFinish: () -> Void

    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.blockIdentitySwapStorage)
    private var blockIdentitySwapStorage: any BlockIdentitySwapStorageProtocol

    private var state = State.active
    private var isInvalidated = false
    // True while the focused placeholder cell must stay alive: removing it before the created
    // block's text view takes first responder briefly dismisses the keyboard (the accessory
    // bar visibly slides down). Cleared when the placeholder's text view resigns.
    private(set) var awaitingFocusHandoff = false

    init(
        virtualId: String,
        document: some BaseDocumentProtocol,
        cursorManager: EditorCursorManager,
        modelsHolder: EditorMainItemModelsHolder,
        collectionController: EditorBlockCollectionController,
        onFinish: @escaping () -> Void
    ) {
        self.virtualId = virtualId
        self.document = document
        self.cursorManager = cursorManager
        self.modelsHolder = modelsHolder
        self.collectionController = collectionController
        self.onFinish = onFinish
    }

    var isMaterialized: Bool {
        if case .materialized = state { return true }
        return false
    }

    var isMaterializing: Bool {
        if case .materializing = state { return true }
        return false
    }

    var materializedBlockId: String? {
        if case let .materialized(info) = state { return info.id }
        return nil
    }

    /// Called when the placeholder is torn down externally (e.g. the editor leaves editing
    /// mode). An in-flight creation still completes — the typed content must not be lost —
    /// but it must no longer grab focus.
    func invalidate() {
        isInvalidated = true
        awaitingFocusHandoff = false
        if let materializedBlockId, cursorManager.blockFocus?.id == materializedBlockId {
            cursorManager.blockFocus = nil
        }
    }

    /// Called when the placeholder's text view resigned first responder after materialization —
    /// the created block's cell has taken over and the placeholder can be removed without
    /// touching the keyboard.
    func completeFocusHandoff() {
        guard case .materialized = state, awaitingFocusHandoff else { return }
        awaitingFocusHandoff = false
        onFinish()
    }

    func materialize(carrying content: BlockText, focusAt: BlockFocusPosition?) async throws -> VirtualTrailingBlockMaterialization {
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
                if !isInvalidated {
                    awaitingFocusHandoff = focusAt.isNotNil
                    applyFocus(focusAt, blockId: info.id)
                }
                onFinish()
                return VirtualTrailingBlockMaterialization(info: info, contentCarried: true)
            } catch {
                state = .active
                anytypeAssertionFailure("Trailing block materialization failed", info: ["error": error.localizedDescription])
                throw error
            }
        }
    }

    func dismiss() {
        guard case .active = state else { return }
        onFinish()
    }

    func dismissAndFocusPreviousBlock() {
        guard case .active = state else { return }
        let previousModel = modelsHolder.findModel(beforeBlockId: virtualId, acceptingTypes: BlockContentType.allTextTypes)
        onFinish()
        previousModel?.set(focus: .end)
    }

    private func createBlock(carrying content: BlockText) async throws -> BlockInformation {
        let info = BlockInformation.empty(content: .text(content))
        AnytypeAnalytics.instance().logCreateBlock(type: info.content.type, spaceId: document.spaceId)
        let blockId = try await blockService.add(
            contextId: document.objectId,
            targetId: "",
            info: info,
            position: .bottom
        )
        SessionCreatedBlockIdsStorage.shared.register(blockId)
        blockIdentitySwapStorage.register(blockId)
        if let containerInfo = document.infoContainer.get(id: blockId),
           containerInfo.configurationData.parentId.isNotNil {
            return containerInfo
        }
        // The creation event may not be applied yet when the response returns; downstream
        // consumers (keyboard handler) need at least id and parentId.
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

    private func applyFocus(_ position: BlockFocusPosition?, blockId: String) {
        guard let position else { return }
        cursorManager.blockFocus = BlockFocus(id: blockId, position: position)
        // If the created block's cell is already built, force a reconfigure so the pending
        // focus is consumed now instead of on some later unrelated reconfigure.
        if let model = modelsHolder.blocksMapping[blockId] {
            collectionController.reconfigure(items: [.block(model)])
        }
    }
}
