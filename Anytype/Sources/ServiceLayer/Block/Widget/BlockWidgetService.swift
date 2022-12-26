import Foundation
import ProtobufMessages

import BlocksModels
import AnytypeCore

protocol BlockWidgetServiceProtocol {
    func createBlockWidget(contextId: String, info: BlockInformation, layout: BlockWidget.Layout) async throws
}

final class BlockWidgetService: BlockWidgetServiceProtocol {
    
    // MARK: - BlockWidgetServiceProtocol
    
    func createBlockWidget(contextId: String, info: BlockInformation, layout: BlockWidget.Layout) async throws {
        
        guard let block = BlockInformationConverter.convert(information: info) else {
            throw AnytypeAssertionFailureWithError("createBlockWidget", domain: .blockWidgetService)
        }
        
        let result = try await Anytype_Rpc.Block.CreateWidget.Service
            .invocation(contextID: contextId, block: block, widgetLayout: layout.asMiddleware)
            .invoke(errorDomain: .blockWidgetService)
        
        EventsBunch(event: result.event).send()
    }
}
