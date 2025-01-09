import SwiftUI
import Services
import AnytypeCore


struct SpaceHubDropDelegate: DropDelegate {
    
    let destinationItem: ParticipantSpaceViewData
    @Binding var allSpaces: [ParticipantSpaceViewData]?
    @Binding var draggedItem: ParticipantSpaceViewData?
    @Binding var initialIndex: Int?
    
    @Injected(\.spaceOrderService)
    private var spaceOrderService: any SpaceOrderServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
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
        guard destinationSpace.spaceView.isPinned || !FeatureFlags.pinnedSpaces else { return }
        
        allSpaces.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex)
        )
        let newOrder = allSpaces
            .filter({ $0.spaceView.isPinned })
            .map(\.spaceView.id)
        
        if FeatureFlags.pinnedSpaces {
            Task {
                try await spaceOrderService.setOrder(
                    spaceViewIdMoved: draggedItem.spaceView.id, newOrder: newOrder
                )
            }
        } else {
            let destinationIndex = toIndex > initialIndex! ? toIndex - 1 : toIndex + 1
            if let destinationItem = allSpaces[safe: destinationIndex] {
                Task { await workspaceStorage.move(space: draggedItem.spaceView, after: destinationItem.spaceView) }
            }
        }
    }
}
