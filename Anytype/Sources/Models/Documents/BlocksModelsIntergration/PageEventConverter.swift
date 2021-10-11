import Foundation
import SwiftProtobuf
import BlocksModels
import ProtobufMessages

struct PageData {
    let rootId: String
    let blocks: [BlockInformation]
    let details: [ObjectDetails]
}

enum PageEventConverter {
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
    static func convert(
        blocks: [Anytype_Model_Block],
        details: [Anytype_Event.Object.Details.Set],
        smartblockType: Anytype_Model_SmartBlockType
    ) -> PageData? {
        let root = blocks.first {
            guard case .smartblock = $0.content else {
                return false
            }
            return true
        }
                
        let parsedBlocks = blocks.compactMap {
            BlockInformationConverter.convert(block: $0)
        }
       
        let parsedDetails = details.map {
            ObjectDetails(
                MiddlewareDetailsConverter.convertSetEvent($0)
            )
        }
        
        guard let rootId = root?.id else { return nil }
        
        return PageData(
            rootId: rootId,
            blocks: parsedBlocks,
            details: parsedDetails
        )
    }
    
}
