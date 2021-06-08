struct Converter {
    struct Default {
        func callAsFunction(_ value: ServiceSuccess) -> PackOfEvents {
            .init(contextId: value.contextID, events: value.messages, ourEvents: [])
        }
        static let `default`: Self = .init()
        static func convert(_ value: ServiceSuccess) -> PackOfEvents {
            self.default(value)
        }
    }
    struct Add {
        func callAsFunction(_ value: ServiceSuccess) -> PackOfEvents {
            let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }

            guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }

            let nextBlockId = addedBlock.id

            return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                .setFocus(.init(blockId: nextBlockId, position: .beginning))
            ])
        }
        static let `default`: Self = .init()
        static func convert(_ value: ServiceSuccess) -> PackOfEvents {
            self.default(value)
        }
    }
    struct Split {
        func callAsFunction(_ value: ServiceSuccess) -> PackOfEvents {
            /// Find added block.
            let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }
            guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                assertionFailure("blocks.split.afterUpdate can't find added block")
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }

            /// Find set children ids.
            let setChildrenMessage = value.messages.first { $0.value == .blockSetChildrenIds($0.blockSetChildrenIds)}
            guard let setChildrenEvent = setChildrenMessage?.blockSetChildrenIds else {
                assertionFailure("blocks.split.afterUpdate can't find set children event")
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }

            let addedBlockId = addedBlock.id

            /// Find a block after added block, because we insert previous block.
            guard let addedBlockIndex = setChildrenEvent.childrenIds.firstIndex(where: { $0 == addedBlockId }) else {
                assertionFailure("blocks.split.afterUpdate can't find index of added block in children ids.")
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }

            /// If we are adding as bottom, we don't need to find block after added block.
            /// Our addedBlockIndex is focused index.
            let focusedIndex = addedBlockIndex
            //setChildrenEvent.childrenIds.index(after: addedBlockIndex)

            /// Check that our childrenIds collection indices contains index.
            guard setChildrenEvent.childrenIds.indices.contains(focusedIndex) else {
                assertionFailure("blocks.split.afterUpdate children ids doesn't contain index of focused block.")
                return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }

            let focusedBlockId = setChildrenEvent.childrenIds[focusedIndex]

            return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                .setFocus(.init(blockId: focusedBlockId, position: .beginning))
            ])
        }
        static let `default`: Self = .init()
        static func convert(_ value: ServiceSuccess) -> PackOfEvents {
            self.default(value)
        }
    }
    struct TurnInto {
        struct Text {
            func callAsFunction(_ value: ServiceSuccess) -> PackOfEvents {
                let textMessage = value.messages.first { $0.value == .blockSetText($0.blockSetText) }

                guard let changedBlock = textMessage?.blockSetText else {
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                let focusedBlockId = changedBlock.id

                return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                    .setFocus(.init(blockId: focusedBlockId, position: .beginning))
                ])
            }
            static let `default`: Self = .init()
            static func convert(_ value: ServiceSuccess) -> PackOfEvents {
                self.default(value)
            }
        }
    }

    struct Delete {
        func callAsFunction(_ value: ServiceSuccess) -> PackOfEvents {
            .init(contextId: value.contextID, events: value.messages, ourEvents: [])
        }
        static let `default`: Self = .init()
        static func convert(_ value: ServiceSuccess) -> PackOfEvents {
            self.default(value)
        }
    }
}
