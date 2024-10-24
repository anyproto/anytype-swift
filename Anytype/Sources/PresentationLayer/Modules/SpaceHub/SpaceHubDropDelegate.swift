import SwiftUI


struct SpaceHubDropDelegate: DropDelegate {
    
    let destinationItem: ParticipantSpaceViewData
    @Binding var allSpaces: [ParticipantSpaceViewData]?
    @Binding var draggedItem: ParticipantSpaceViewData?
    @Binding var initialIndex: Int?
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let allSpaces, let draggedItem, let initialIndex else { return false }
        
        guard let finalIndex = allSpaces.firstIndex(of: destinationItem) else { return false }
        guard finalIndex != initialIndex else { return false }
        
        let destinationIndex = finalIndex > initialIndex ? finalIndex - 1 : finalIndex + 1
        guard let destinationItem = allSpaces[safe: destinationIndex] else { return false }
        
        workspacesStorage.move(space: draggedItem.spaceView, after: destinationItem.spaceView)
        
        self.draggedItem = nil
        self.initialIndex = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let allSpaces, let draggedItem else { return }
        guard let fromIndex = allSpaces.firstIndex(of: draggedItem) else { return }
        guard let toIndex = allSpaces.firstIndex(of: destinationItem) else { return }
        guard fromIndex != toIndex else { return }
        
        if initialIndex.isNil { initialIndex = fromIndex }
        
        withAnimation {
            self.allSpaces?.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex)
            )
        }
    }
}
