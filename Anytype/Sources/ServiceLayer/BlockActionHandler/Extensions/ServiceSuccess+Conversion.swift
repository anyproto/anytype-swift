extension ServiceSuccess {
    var defaultEvent: PackOfEvents {
        PackOfEvents(events: messages, localEvents: [])
    }
    
    var turnIntoTextEvent: PackOfEvents {
        let textMessage = messages.first { $0.value == .blockSetText($0.blockSetText) }
        
        let localEvents: [LocalEvent] = textMessage.flatMap {
            [.setFocus(blockId: $0.blockSetText.id, position: .beginning)]
        } ?? []

        return PackOfEvents(events: messages, localEvents: localEvents)
    }
    
    var addEvent: PackOfEvents {
        let addEntryMessage = messages.first { $0.value == .blockAdd($0.blockAdd) }
        let localEvents: [LocalEvent] = addEntryMessage?.blockAdd.blocks.first.flatMap {
            [.setFocus(blockId: $0.id, position: .beginning)]
        } ?? []
        
        return .init(events: messages, localEvents: localEvents)
    }
    
    var splitEvent: PackOfEvents {
        /// Find added block.
        let addEntryMessage = messages.first { $0.value == .blockAdd($0.blockAdd) }
        guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
            assertionFailure("blocks.split.afterUpdate can't find added block")
            return self.defaultEvent
        }

        /// Find set children ids.
        let setChildrenMessage = messages.first { $0.value == .blockSetChildrenIds($0.blockSetChildrenIds)}
        guard let setChildrenEvent = setChildrenMessage?.blockSetChildrenIds else {
            assertionFailure("blocks.split.afterUpdate can't find set children event")
            return self.defaultEvent
        }

        let addedBlockId = addedBlock.id

        /// Find a block after added block, because we insert previous block.
        guard let addedBlockIndex = setChildrenEvent.childrenIds.firstIndex(where: { $0 == addedBlockId }) else {
            assertionFailure("blocks.split.afterUpdate can't find index of added block in children ids.")
            return self.defaultEvent
        }

        /// If we are adding as bottom, we don't need to find block after added block.
        /// Our addedBlockIndex is focused index.
        let focusedIndex = addedBlockIndex
        //setChildrenEvent.childrenIds.index(after: addedBlockIndex)

        /// Check that our childrenIds collection indices contains index.
        guard setChildrenEvent.childrenIds.indices.contains(focusedIndex) else {
            assertionFailure("blocks.split.afterUpdate children ids doesn't contain index of focused block.")
            return self.defaultEvent
        }

        let focusedBlockId = setChildrenEvent.childrenIds[focusedIndex]

        return PackOfEvents(events: messages, localEvents: [
            .setFocus(blockId: focusedBlockId, position: .beginning)
        ])
    }
}
