import BlocksModels
import UIKit

protocol BlockActionServiceProtocol {
    typealias Conversion = (ServiceSuccess) -> (PackOfEvents)
    
    func configured(documentId: String) -> Self
    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ())
    
    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(blockId: BlockId, type: BlockContent, shouldSetFocusOnUpdate: Bool)
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool)
    func addChild(info: BlockInformation, parentBlockId: BlockId)
    
    func merge(firstBlockId: BlockId, secondBlockId: BlockId, ourEvents: [OurEvent])
    
    func delete(blockId: BlockId, completion: @escaping Conversion)
    
    func createPage(position: BlockPosition)
    
    func split(info: BlockInformation, oldText: String, newBlockContentType: BlockText.ContentType, shouldSetFocusOnUpdate: Bool)
    
    func bookmarkFetch(blockId: BlockId, url: String)
    
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor)
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor)
    
    func checked(blockId: BlockId, newValue: Bool)
    
    func duplicate(blockId: BlockId)
    
    func setFields(contextID: BlockId, blockFields: [BlockFields])
    
    func receiveOurEvents(_ events: [OurEvent])
}
