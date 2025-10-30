import SwiftUI
import Services
import AnytypeCore


struct SpaceHubDropDelegate: DropDelegate {
    
    let destinationSpaceViewId: String?
    @Binding var allSpaces: [ParticipantSpaceViewDataWithPreview]?
    @Binding var draggedSpaceViewId: String?
    @Binding var initialIndex: Int?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let allSpaces, draggedSpaceViewId.isNotNil, let initialIndex else { return false }
        
        guard let finalIndex = allSpaces.firstIndex(where: { $0.spaceView.id == destinationSpaceViewId }) else { return false }
        guard finalIndex != initialIndex else { return false }
        
        self.draggedSpaceViewId = nil
        self.initialIndex = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard var allSpaces, let draggedSpaceViewId else { return }
        guard let fromIndex = allSpaces.firstIndex(where: { $0.space.spaceView.id == draggedSpaceViewId } ) else { return }
        guard let toIndex = allSpaces.firstIndex(where: { $0.space.spaceView.id == destinationSpaceViewId } ) else { return }
        
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
                spaceViewIdMoved: draggedSpaceViewId, newOrder: newOrder
            )
            AnytypeAnalytics.instance().logReorderSpace()
        }
    }
}
