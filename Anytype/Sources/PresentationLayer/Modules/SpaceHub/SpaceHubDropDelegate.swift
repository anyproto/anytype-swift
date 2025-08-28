import SwiftUI
import Services
import AnytypeCore


struct SpaceHubDropDelegate: DropDelegate {
    
    let destinationItem: ParticipantSpaceViewDataWithPreview
    @Binding var allSpaces: [ParticipantSpaceViewDataWithPreview]?
    @Binding var draggedItem: ParticipantSpaceViewDataWithPreview?
    @Binding var initialIndex: Int?
    
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
        guard let fromIndex = allSpaces.firstIndex(where: { $0.space.id == draggedItem.space.id } ) else { return }
        guard let toIndex = allSpaces.firstIndex(where: { $0.space.id == destinationItem.space.id } ) else { return }
        
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
            // Doesn't use @Injected(\.spaceOrderService)
            // Delegate is created for each update. Resolving DI takes time on the main thread.
            let spaceOrderService = Container.shared.spaceOrderService()
            
            try await spaceOrderService.setOrder(
                spaceViewIdMoved: draggedItem.spaceView.id, newOrder: newOrder
            )
            AnytypeAnalytics.instance().logReorderSpace()
        }
    }
}
