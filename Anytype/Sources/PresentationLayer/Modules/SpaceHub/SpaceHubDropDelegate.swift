import SwiftUI
import Services


struct SpaceHubDropDelegate: DropDelegate {
    
    let destinationItem: ParticipantSpaceViewData
    @Binding var allSpaces: [ParticipantSpaceViewData]?
    @Binding var draggedItem: ParticipantSpaceViewData?
    @Binding var initialIndex: Int?
    
    @Injected(\.spaceOrderService)
    private var spaceOrderService: any SpaceOrderServiceProtocol
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let allSpaces, draggedItem.isNotNil, let initialIndex else { return false }
        
        guard let finalIndex = allSpaces.firstIndex(of: destinationItem) else { return false }
        guard finalIndex != initialIndex else { return false }
        
        self.draggedItem = nil
        self.initialIndex = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard var allSpaces, let draggedItem else { return }
        guard let fromIndex = allSpaces.firstIndex(of: draggedItem) else { return }
        guard let toIndex = allSpaces.firstIndex(of: destinationItem) else { return }
        
        guard fromIndex != toIndex else { return }
        
        if initialIndex.isNil { initialIndex = fromIndex }
        
        guard let destinationSpace = allSpaces[safe: toIndex] else { return }
        guard destinationSpace.spaceView.isPinned else { return }
        
        allSpaces.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex)
        )
        let newOrder = allSpaces
            .filter({ $0.spaceView.isPinned })
            .map(\.spaceView.id)
        
        Task {
            try await spaceOrderService.setOrder(
                spaceViewIdMoved: draggedItem.spaceView.id, newOrder: newOrder
            )
        }
    }
}
