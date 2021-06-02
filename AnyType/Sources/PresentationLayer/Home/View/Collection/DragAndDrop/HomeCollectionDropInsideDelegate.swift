import SwiftUI


struct HomeCollectionDropInsideDelegate: DropDelegate {
    let delegateData: PageCellData
    @Binding var cellData: [PageCellData]
    @Binding var data: DropData
    
    func dropEntered(info: DropInfo) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        guard let draggingCellData = data.draggingCellData,
              let fromIndex = cellData.index(id: draggingCellData.id),
              let toIndex = cellData.index(id: delegateData.id) else {
            return
        }
        guard delegateData.id != draggingCellData.id else {
            return
        }
        
        let dropAfter = toIndex > fromIndex
        data.dropPositionCellData = delegateData
        data.direction = dropAfter ? .after : .before
        
        
        cellData.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: dropAfter ? toIndex + 1 : toIndex
        )
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingCellData = data.draggingCellData,
              let dropPositionCellData = data.dropPositionCellData,
              let direction = data.direction else {
            return false
        }
        
        guard let homeBlockId = MiddlewareConfiguration.shared?.homeBlockID else {
            assertionFailure("Shared configuration is nil")
            return false
        }
        
        ObjectActionsService().move(
            dashboadId: homeBlockId,
            blockId: draggingCellData.id,
            dropPositionblockId: dropPositionCellData.id,
            position: direction.toBlockModel()
        )
        
        data.direction = nil
        data.draggingCellData = nil
        data.dropPositionCellData = nil
        
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
