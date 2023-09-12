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
            info.updated(horizontalAlignment: data.align.asBlockModel)
        }
    }
}
