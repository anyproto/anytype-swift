import Foundation
import ProtobufMessages

import BlocksModels
import AnytypeCore

protocol BlockWidgetServiceProtocol {
    func createWidgetBlock(contextId: String, info: BlockInformation, layout: BlockWidget.Layout) async throws
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws
}

final class BlockWidgetService: BlockWidgetServiceProtocol {
    
    // MARK: - BlockWidgetServiceProtocol
    
    func createWidgetBlock(contextId: String, info: BlockInformation, layout: BlockWidget.Layout) async throws {
        
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw anytypeAssertionFailureWithError("createBlockWidget", domain: .blockWidgetService)
        }
        
        let result = try await Anytype_Rpc.Block.CreateWidget.Service
            .invocation(contextID: contextId, block: block, widgetLayout: layout.asMiddleware)
            .invoke(errorDomain: .blockWidgetService)
        
        EventsBunch(event: result.event).send()
    }
    
    func removeWidgetBlock(contextId: String, widgetBlockId: String) async throws {
        let result = try await Anytype_Rpc.Block.ListDelete.Service
            .invocation(contextID: contextId, blockIds: [widgetBlockId])
            .invoke(errorDomain: .blockWidgetService)
        
        EventsBunch(event: result.event).send()
    }
}
