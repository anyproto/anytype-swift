import SwiftUI

final class KanbanCardDropInsideDelegate: DropDelegate {
    let dragAndDropDelegate: KanbanDragAndDropDelegate
    let droppingCard: SetContentViewItemConfiguration?
    let toGroupId: String
    @Binding var data: KanbanCardDropData
    
    init(
        dragAndDropDelegate: KanbanDragAndDropDelegate,
        droppingCard: SetContentViewItemConfiguration?,
        toGroupId: String,
        data: Binding<KanbanCardDropData>
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

        dragAndDropDelegate.onDrag(
            from: KanbanDragAndDropConfiguration(
                groupId: fromGroupId,
                configurationId: draggingCard.id
            ),
            to: KanbanDragAndDropConfiguration(
                groupId: toGroupId,
                configurationId: droppingCard?.id
            )
        )

        if fromGroupId != toGroupId {
            data.fromGroupId = toGroupId
        }

        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        data.droppingCard = droppingCard
        data.toGroupId = toGroupId
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let initialFromGroupId = data.initialFromGroupId,
              let toGroupId = data.toGroupId,
              let configurationId = data.draggingCard?.id else {
            return false
        }
        
        clearDropData()
        
        return dragAndDropDelegate.onDrop(
            configurationId: configurationId,
            fromGroupId: initialFromGroupId,
            toGroupId: toGroupId
        )
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    private func clearDropData() {
        data.initialFromGroupId = nil
        data.fromGroupId = nil
        data.toGroupId = nil
        data.draggingCard = nil
        data.droppingCard = nil
    }
}
