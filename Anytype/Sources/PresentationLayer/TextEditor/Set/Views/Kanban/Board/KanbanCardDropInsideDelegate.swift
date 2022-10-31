import SwiftUI

struct KanbanCardDropInsideDelegate: DropDelegate {
    let dragAndDropDelegate: KanbanDragAndDropDelegate
    let droppingData: SetContentViewItemConfiguration
    let toSubId: SubscriptionId
    @Binding var data: KanbanCardDropData
    
    func dropEntered(info: DropInfo) {
        guard let draggingCellData = data.draggingCard, let fromSubId = data.fromSubId else {
            return
        }
        
        dragAndDropDelegate.onDrag(
            from: KanbanDragAndDropConfiguration(
                subscriptionId: fromSubId,
                configurationId: draggingCellData.id
            ),
            to: KanbanDragAndDropConfiguration(
                subscriptionId: toSubId,
                configurationId: droppingData.id
            )
        )
        
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        data.droppingData = droppingData
        data.toSubId = toSubId
        print("\(droppingData.title)")
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let fromSubId = data.fromSubId,
              let toSubId = data.toSubId else {
            return false
        }
        
        data.draggingCard = nil
        data.droppingData = nil
        data.fromSubId = nil
        data.toSubId = nil
        
        return dragAndDropDelegate.onDrop(fromSubId: fromSubId, toSubId: toSubId)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
