import AnytypeCore

extension ResponseEvent {
    var defaultEvent: PackOfEvents {
        PackOfEvents(middlewareEvents: messages, localEvents: [])
    }
    
    var turnIntoTextEvent: PackOfEvents {
        let textMessage = messages.first { $0.value == .blockSetText($0.blockSetText) }
        
        let localEvents: [LocalEvent] = textMessage.flatMap {
            [.setFocus(blockId: $0.blockSetText.id, position: .beginning)]
        } ?? []

        return PackOfEvents(middlewareEvents: messages, localEvents: localEvents)
    }
    
    var addEvent: PackOfEvents {
        let addEntryMessage = messages.first { $0.value == .blockAdd($0.blockAdd) }
        let localEvents: [LocalEvent] = addEntryMessage?.blockAdd.blocks.first.flatMap {
            [.setFocus(blockId: $0.id, position: .beginning)]
        } ?? []
        
        return .init(middlewareEvents: messages, localEvents: localEvents)
    }
}
