import Foundation
import ProtobufMessages
import AnytypeCore

public protocol BlockWidgetServiceProtocol: Sendable {
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, limit: Int, position: WidgetPosition) async throws
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws
    func setLayout(contextId: String, widgetBlockId: String, layout: BlockWidget.Layout) async throws
    func setViewId(contextId: String, widgetBlockId: String, viewId: String) async throws
}

public extension BlockWidgetServiceProtocol {
    /// Toggle a widget-block entry inside `contextId` for the given `targetObjectId`.
    /// If an existing widget block references the target, it is removed; otherwise a
    /// new widget block is inserted via `.above(firstChildId)` with `.end` fallback.
    /// Shared between channel-pin (IOS-5864 `WidgetActionsViewCommonMenuProvider`) and
    /// personal-favorite (`PersonalFavoritesService`) toggle flows — they differ only
    /// in `contextId`, `layout`, and `limit`.
    func toggleWidgetBlock(
        contextId: String,
        targetObjectId: String,
        existingWidgetBlockId: String?,
        firstChildBlockId: String?,
        layout: BlockWidget.Layout,
        limit: Int
    ) async throws {
        if let existingWidgetBlockId {
            try await removeWidgetBlock(contextId: contextId, widgetBlockId: existingWidgetBlockId)
        } else {
            let position: WidgetPosition = firstChildBlockId.map { .above(widgetId: $0) } ?? .end
            try await createWidgetBlock(
                contextId: contextId,
                sourceId: targetObjectId,
                layout: layout,
                limit: limit,
                position: position
            )
        }
    }
}

final class BlockWidgetService: BlockWidgetServiceProtocol {
        
    // MARK: - BlockWidgetServiceProtocol
    
    public func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, limit: Int, position: WidgetPosition) async throws {
        
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: sourceId)))
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("Block not created")
        }
        
        try await ClientCommands.blockCreateWidget(.with {
            $0.contextID = contextId
            $0.targetID = position.targetId
            $0.block = block
            $0.position = position.middlePosition
            $0.widgetLayout = layout
            $0.objectLimit = Int32(limit)
        }).invoke()
    }
    
    public func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws {
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = [widgetBlockId]
        }).invoke()
    }
    
    public func setLayout(contextId: String, widgetBlockId: String, layout: BlockWidget.Layout) async throws {
        _ = try? await ClientCommands.blockWidgetSetLayout(.with {
            $0.contextID = contextId
            $0.blockID = widgetBlockId
            $0.layout = layout
        }).invoke()
    }
    
    public func setViewId(contextId: String, widgetBlockId: String, viewId: String) async throws {
        _ = try? await ClientCommands.blockWidgetSetViewId(.with {
            $0.contextID = contextId
            $0.blockID = widgetBlockId
            $0.viewID = viewId
        }).invoke()
    }
}
