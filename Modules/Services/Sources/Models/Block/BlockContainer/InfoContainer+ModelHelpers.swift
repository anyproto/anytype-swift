import Foundation
import AnytypeCore

public extension InfoContainerProtocol {
    
    func updateDataview(blockId: BlockId, update updateAction: (BlockDataview) -> (BlockDataview)) {
        update(blockId: blockId) { info in
            guard case let .dataView(dataView) = info.content else {
                anytypeAssertionFailure("Not a dataview", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .dataView(updateAction(dataView)))
        }
    }
    
    func updateRelation(blockId: BlockId, update updateAction: (BlockRelation) -> (BlockRelation)) {
        update(blockId: blockId) { info in
            guard case let .relation(relation) = info.content else {
                anytypeAssertionFailure("Not a relation", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .relation(updateAction(relation)))
        }
    }
    
    func updateWidget(blockId: BlockId, update updateAction: (BlockWidget) -> (BlockWidget)) {
        update(blockId: blockId) { info in
            guard case let .widget(widget) = info.content else {
                anytypeAssertionFailure("Not a widget", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .widget(updateAction(widget)))
        }
    }
    
    func updateFile(blockId: BlockId, update updateAction: (BlockFile) -> (BlockFile)) {
        update(blockId: blockId) { info in
            guard case let .file(file) = info.content else {
                anytypeAssertionFailure("Not a file", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .file(updateAction(file)))
        }
    }
    
    func updateDivider(blockId: BlockId, update updateAction: (BlockDivider) -> (BlockDivider)) {
        update(blockId: blockId) { info in
            guard case let .divider(divider) = info.content else {
                anytypeAssertionFailure("Not a divider", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .divider(updateAction(divider)))
        }
    }

    func updateBookmark(blockId: BlockId, update updateAction: (BlockBookmark) -> (BlockBookmark)) {
        update(blockId: blockId) { info in
            guard case let .bookmark(bookmark) = info.content else {
                anytypeAssertionFailure("Not a bookmark", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .bookmark(updateAction(bookmark)))
        }
    }
    
    func updateLink(blockId: BlockId, update updateAction: (BlockLink) -> (BlockLink)) {
        update(blockId: blockId) { info in
            guard case let .link(link) = info.content else {
                anytypeAssertionFailure("Not a link", info: ["content": "\(info.content.type)"])
                return nil
            }
            
            return info.updated(content: .link(updateAction(link)))
        }
    }
}
