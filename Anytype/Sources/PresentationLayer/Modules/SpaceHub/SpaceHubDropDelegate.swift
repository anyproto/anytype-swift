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
        guard let fromIndex = allSpaces.firstIndex(of: draggedItem) else { return }
        guard let toIndex = allSpaces.firstIndex(of: destinationItem) else { return }
        
        guard fromIndex != toIndex else { return }
        
        if initialIndex.isNil { initialIndex = fromIndex }
        
        guard let destinationSpace = allSpaces[safe: toIndex] else { return }
        
        allSpaces.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex)
        )
        let newOrder = allSpaces
            .map(\.spaceView.id)
        
        // Doesn't use @Injected(\.spaceOrderService)
        // Delegate is created for each update. Resolving DI takes time on the main thread.
        let spaceOrderService = Container.shared.spaceOrderService()
        let workspaceStorage = Container.shared.workspaceStorage()
        
        let destinationIndex = toIndex > initialIndex! ? toIndex - 1 : toIndex + 1
        if let destinationItem = allSpaces[safe: destinationIndex] {
            Task {
                await workspaceStorage.move(space: draggedItem.spaceView, after: destinationItem.spaceView)
                AnytypeAnalytics.instance().logReorderSpace()
            }
        }
    }
}
