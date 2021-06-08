import BlocksModels

extension BlockActionService {
    enum Reaction {
        /// Action type that happens with block.
        ///
        /// View that contain blocks can use this actions type to understant what happened with blocks.
        /// For example, when block deleted we need first set focus to previous block  before model will be updated  to prevent hide keyboard.
        enum ActionType {
            /// Block deleted
            case deleteBlock
            /// Block merged (when we delete block that has text after cursor )
            case merge
        }

        struct ShouldOpenPage {
            struct Payload {
                var blockId: BlockId
            }

            var payload: Payload
        }

        struct ShouldHandleEvent {
            var actionType: ActionType?
            var events: PackOfEvents
        }

        case shouldOpenPage(ShouldOpenPage)
        case shouldHandleEvent(ShouldHandleEvent)
    }
}
