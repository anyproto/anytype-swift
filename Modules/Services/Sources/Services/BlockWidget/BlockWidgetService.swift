import Foundation
import ProtobufMessages
import AnytypeCore

public protocol BlockWidgetServiceProtocol: Sendable {
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, limit: Int, position: WidgetPosition) async throws
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws
    func setLayout(contextId: String, widgetBlockId: String, layout: BlockWidget.Layout) async throws
    func setViewId(contextId: String, widgetBlockId: String, viewId: String) async throws
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
