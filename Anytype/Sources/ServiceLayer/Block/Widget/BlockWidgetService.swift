import Foundation
import ProtobufMessages
import Services
import AnytypeCore

protocol BlockWidgetServiceProtocol {
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, position: WidgetPosition) async throws
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws
    // Delete with widgetsNewApi flag
    func replaceWidgetBlock(contextId: String, widgetBlockId: String, sourceId: String, layout: BlockWidget.Layout) async throws
    func setSourceId(contextId: String, widgetBlockId: String, sourceId: String) async throws
    func setLayout(contextId: String, widgetBlockId: String, layout: BlockWidget.Layout) async throws
}

final class BlockWidgetService: BlockWidgetServiceProtocol {
    
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    
    init(blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol) {
        self.blockWidgetExpandedService = blockWidgetExpandedService
    }
    
    // MARK: - BlockWidgetServiceProtocol
    
    func createWidgetBlock(contextId: String, sourceId: String, layout: BlockWidget.Layout, position: WidgetPosition) async throws {
        
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: sourceId)))
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("Block not created")
        }
        
        try await ClientCommands.blockCreateWidget(.with {
            $0.contextID = contextId
            $0.targetID = position.targetId
            $0.block = block
            $0.position = position.middlePosition
            $0.widgetLayout = layout.asMiddleware
        }).invoke()
    }
    
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws {
        try await ClientCommands.blockListDelete(.with {
            $0.contextID = contextId
            $0.blockIds = [widgetBlockId]
        }).invoke()
    }
    
    func replaceWidgetBlock(contextId: String, widgetBlockId: String, sourceId: String, layout: BlockWidget.Layout) async throws {
        
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: sourceId)))
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("Block not created")
        }
        
        let result = try await ClientCommands.blockCreateWidget(.with {
            $0.contextID = contextId
            $0.targetID = widgetBlockId
            $0.block = block
            $0.position = .replace
            $0.widgetLayout = layout.asMiddleware
        }).invoke()
        
        let expandedState = blockWidgetExpandedService.isExpanded(widgetBlockId: widgetBlockId)
        blockWidgetExpandedService.setState(widgetBlockId: result.blockID, isExpanded: expandedState)
        blockWidgetExpandedService.deleteState(widgetBlockId: widgetBlockId)
    }
    
    func setSourceId(contextId: String, widgetBlockId: String, sourceId: String) async throws {
        _ = try? await ClientCommands.blockWidgetSetTargetId(.with {
            $0.contextID = contextId
            $0.blockID = widgetBlockId
            $0.targetID = sourceId
        }).invoke()
    }
    
    func setLayout(contextId: String, widgetBlockId: String, layout: BlockWidget.Layout) async throws {
        _ = try? await ClientCommands.blockWidgetSetLayout(.with {
            $0.contextID = contextId
            $0.blockID = widgetBlockId
            $0.layout = layout.asMiddleware
        }).invoke()
    }
}
