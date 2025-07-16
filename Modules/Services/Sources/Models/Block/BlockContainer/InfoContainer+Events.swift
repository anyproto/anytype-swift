import Foundation
import ProtobufMessages

public extension InfoContainerProtocol {
    
    func add(data: Anytype_Event.Block.Add) {
        data.blocks
            .compactMap(BlockInformationConverter.convert(block:))
            .forEach { block in
                add(block)
            }
    }
    
    func setFields(data: Anytype_Event.Block.Set.Fields) {
        update(blockId: data.id) { info in
            return info.updated(fields: data.fields.fields)
        }
    }
    
    func delete(data: Anytype_Event.Block.Delete) {
        data.blockIds.forEach { blockId in
            remove(id: blockId)
        }
    }
    
    func setBackgroundColor(data: Anytype_Event.Block.Set.BackgroundColor) {
        update(blockId: data.id, update: { info in
            return info.updated(
                backgroundColor: MiddlewareColor(rawValue: data.backgroundColor) ?? .default
            )
        })
    }
    
    func setAlign(data: Anytype_Event.Block.Set.Align) {
        update(blockId: data.id) { info in
            info.updated(horizontalAlignment: data.align)
        }
    }
    
    func setFile(data: Anytype_Event.Block.Set.File) {
        updateFile(blockId: data.id) { $0.handleSetFile(data: data) }
    }
    
    func setBookmark(data: Anytype_Event.Block.Set.Bookmark) {
        updateBookmark(blockId: data.id) { $0.handleSetBookmark(data: data) }
    }
    
    func setDiv(data: Anytype_Event.Block.Set.Div) {
        updateDivider(blockId: data.id) { $0.handleSetDiv(data: data) }
    }
    
    func setLink(data: Anytype_Event.Block.Set.Link) {
        updateLink(blockId: data.id) { $0.handleSetLink(data: data) }
    }
    
    func setRelation(data: Anytype_Event.Block.Set.Relation) {
        updateRelation(blockId: data.id) { $0.handleSetRelation(data: data) }
    }
    
    func setWidget(data: Anytype_Event.Block.Set.Widget) {
        updateWidget(blockId: data.id) { $0.handleSetWidget(data: data) }
    }
    
    func setLatex(data: Anytype_Event.Block.Set.Latex) {
        updateLatex(blockId: data.id) { $0.handleSetLatex(data: data) }
    }
}
