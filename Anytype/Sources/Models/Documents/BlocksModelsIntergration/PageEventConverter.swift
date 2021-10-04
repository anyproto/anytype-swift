import Foundation
import SwiftProtobuf
import BlocksModels
import ProtobufMessages

struct PageEvent {
    let rootId: String
    let blocks: [BlockInformation]
    let details: [DetailsData]
    
    static func empty() -> Self {
        PageEvent(rootId: "", blocks: [], details: [])
    }
}

final class PageEventConverter {
    /// New cool parsing that takes into account details and smartblock type.
    ///
    /// Discussion.
    ///
    /// Our parsing happens, of course, from some events.
    /// Most of our events will send common data as `contextID`.
    /// Also, blocks can't be delivered to us without some `context` of `Outer block`.
    /// This `Outer block` is named as `Smartblock` in middleware model.
    ///
    /// * This block could contain `details`. It is a structure ( or a dictionary ) with predefined fields.
    /// * This block also has type `smartblockType`. It is a `.case` from enumeration.
    ///
    func convert(
        blocks: [Anytype_Model_Block],
        details: [Anytype_Event.Object.Details.Set],
        smartblockType: Anytype_Model_SmartBlockType
    ) -> PageEvent {
        
        let root = blocks.first(where: {
            switch $0.content {
            case .smartblock: return true
            default: return false
            }
        })
                
        let parsedBlocks = blocks.compactMap(BlockInformationConverter.convert(block:))
        
        let parsedDetails = details.map { event -> DetailsData in
            let rawDetails = BlocksModelsDetailsConverter.asModel(event: event)
            
            return DetailsData(rawDetails: rawDetails, blockId: event.id)
        }
        
        guard let rootId = root?.id else {
            return .empty()
        }
        
        return .init(rootId: rootId, blocks: parsedBlocks, details: parsedDetails)
    }
}
