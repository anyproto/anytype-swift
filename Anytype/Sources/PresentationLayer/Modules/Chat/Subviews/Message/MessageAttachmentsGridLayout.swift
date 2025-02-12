import Foundation
import Factory

protocol MessageAttachmentsGridLayoutBuilderProtocol: Sendable {
    func makeGridRows(countItems: Int) -> [Int]
}

final class MessageAttachmentsGridLayoutBuilder: MessageAttachmentsGridLayoutBuilderProtocol, Sendable {
    func makeGridRows(countItems: Int) -> [Int] {
        
        var items = countItems
        var result = [Int]()
        
        while items > 0 {
            let newItems2 = items - 2
            let newItems3 = items - 3
            
            if newItems3 >= 2 || newItems3 == 0 {
                result.append(3)
                items = newItems3
            } else if newItems2 > 1 || newItems2 == 0 {
                result.append(2)
                items = newItems2
            } else { // items == 1
                result.append(1)
                items = 0
            }
            
        }
        
        return result.reversed()
    }
}

extension Container {
    var messageAttachmentsGridLayoutBuilder: Factory<any MessageAttachmentsGridLayoutBuilderProtocol> {
        self { MessageAttachmentsGridLayoutBuilder() }
    }
}
