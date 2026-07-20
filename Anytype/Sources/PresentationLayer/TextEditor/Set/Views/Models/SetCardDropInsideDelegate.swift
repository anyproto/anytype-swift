import SwiftUI

final class SetCardDropInsideDelegate: DropDelegate {
    let dragAndDropDelegate: any SetDragAndDropDelegate
    let droppingCard: SetContentViewItemConfiguration?
    let toGroupId: String
    @Binding var data: SetCardDropData
    
    init(
        dragAndDropDelegate: some SetDragAndDropDelegate,
        droppingCard: SetContentViewItemConfiguration?,
        toGroupId: String,
        data: Binding<SetCardDropData>
    ) {
        self.dragAndDropDelegate = dragAndDropDelegate
        self.droppingCard = droppingCard
        self.toGroupId = toGroupId
        self._data = data
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggingCard = data.draggingCard, let fromGroupId = data.fromGroupId else {
            return
        }

        // A background target (no specific card under the drag) appends only when coming from
        // another column; inside the card's own column it must not teleport the card to the
        // end - it just arms performDrop for a release over the column's empty areas.
        let movesCard = droppingCard != nil || fromGroupId != toGroupId
        if movesCard {
            dragAndDropDelegate.onDrag(
                from: SetDragAndDropConfiguration(
                    groupId: fromGroupId,
                    configurationId: draggingCard.id
                ),
                to: SetDragAndDropConfiguration(
                    groupId: toGroupId,
                    configurationId: droppingCard?.id
                )
            )

            if fromGroupId != toGroupId {
                data.fromGroupId = toGroupId
            }

            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }

        data.droppingCard = droppingCard
        data.toGroupId = toGroupId
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let initialFromGroupId = data.initialFromGroupId,
              let toGroupId = data.toGroupId,
              let configurationId = data.draggingCard?.id else {
            return false
        }
        
        data.clear()
        
        return dragAndDropDelegate.onDrop(
            configurationId: configurationId,
            fromGroupId: initialFromGroupId,
            toGroupId: toGroupId
        )
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
