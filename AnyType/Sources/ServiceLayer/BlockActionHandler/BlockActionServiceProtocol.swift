import BlocksModels
import UIKit

protocol BlockActionServiceProtocol {
    typealias Conversion = (ServiceSuccess) -> (PackOfEvents)
    
    func configured(documentId: String) -> Self
    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ()) -> Self
    
    func upload(block: BlockInformation, filePath: String)
    
    func turnInto(block: BlockInformation, type: BlockContent, shouldSetFocusOnUpdate: Bool)
    
    func add(newBlock: BlockInformation, afterBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool)
    func addChild(childBlock: BlockInformation, parentBlockId: BlockId)
    
    func merge(firstBlock: BlockInformation, secondBlock: BlockInformation, _ completion: @escaping Conversion)
    
    func delete(block: BlockInformation, completion: @escaping Conversion)
    
    func createPage(afterBlock: BlockInformation, position: BlockPosition)
    
    func split(block: BlockInformation, oldText: String, newBlockContentType: BlockText.ContentType, shouldSetFocusOnUpdate: Bool)
    
    func bookmarkFetch(block: BlockInformation, url: String)
    
    func setBackgroundColor(block: BlockInformation, color: UIColor)
    
    func checked(block: BlockActiveRecordModelProtocol, newValue: Bool)
    
    func duplicate(block: BlockInformation)
    
    func receiveOurEvents(_ events: [OurEvent])
}

extension BlockActionServiceProtocol {
    func add(newBlock: BlockInformation, afterBlockId: BlockId, position: BlockPosition = .bottom, shouldSetFocusOnUpdate: Bool) {
        add(newBlock: newBlock, afterBlockId: afterBlockId, position: position, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
    }
    
    func createPage(afterBlock: BlockInformation, position: BlockPosition = .bottom) {
        createPage(afterBlock: afterBlock, position: position)
    }
    
    func merge(firstBlock: BlockInformation, secondBlock: BlockInformation, _ completion: @escaping Conversion = Converter.Default.convert) {
        merge(firstBlock: firstBlock, secondBlock: secondBlock, completion)
    }
}
