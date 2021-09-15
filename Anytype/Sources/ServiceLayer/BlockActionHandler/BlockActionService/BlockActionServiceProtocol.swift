import BlocksModels
import UIKit

protocol BlockActionServiceProtocol {
    typealias Conversion = (ResponseEvent) -> (PackOfEvents)
    
    func configured(documentId: String) -> Self
    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ())
    
    func upload(blockId: BlockId, filePath: String)
    
    func turnInto(blockId: BlockId, type: BlockContentType, shouldSetFocusOnUpdate: Bool)
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> ())
    
    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool)
    func addChild(info: BlockInformation, parentBlockId: BlockId)
    
    func merge(firstBlockId: BlockId, secondBlockId: BlockId, localEvents: [LocalEvent])
    
    func delete(blockId: BlockId, completion: @escaping Conversion)
    
    func createPage(position: BlockPosition)
    
    func split(info: BlockInformation, oldText: String, newBlockContentType: BlockText.Style)
    
    func bookmarkFetch(blockId: BlockId, url: String)
    
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor)
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor)
    
    func checked(blockId: BlockId, newValue: Bool)
    
    func duplicate(blockId: BlockId)
    
    func setFields(contextID: BlockId, blockFields: [BlockFields])
    
    func receivelocalEvents(_ events: [LocalEvent])
}
