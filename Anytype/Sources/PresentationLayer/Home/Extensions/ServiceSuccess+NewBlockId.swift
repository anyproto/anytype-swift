import ProtobufMessages

extension ResponseEvent {
    var newBlockId: String? {
        let blockAdd = self.messages.compactMap { message -> Anytype_Event.Block.Add?  in
            if case let .blockAdd(value)? = message.value {
                return value
            }
            
            return nil
        }.first
        
        return blockAdd?.blocks.first?.link.targetBlockID
    }
}
