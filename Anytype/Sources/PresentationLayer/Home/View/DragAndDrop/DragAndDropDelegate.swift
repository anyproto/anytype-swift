import Foundation
import AnytypeCore

// MARK: - CellDataManager
protocol DragAndDropDelegate {
    func onDrag(from: PageCellData, to: PageCellData) -> DropData.Direction?
    func onDrop(from: PageCellData, to: PageCellData, direction: DropData.Direction) -> Bool
}

// Drag and drop only for favorites
extension HomeViewModel: DragAndDropDelegate {
    func onDrag(from: PageCellData, to: PageCellData) -> DropData.Direction? {
        guard from.id != to.id else {
            return nil
        }
        
        guard let fromIndex = favoritesCellData.index(id: from.id),
              let toIndex = favoritesCellData.index(id: to.id) else {
            return nil
        }
        
        let dropAfter = toIndex > fromIndex
        
        favoritesCellData.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: dropAfter ? toIndex + 1 : toIndex
        )
        
        return dropAfter ? .after : .before
    }
    
    func onDrop(from: PageCellData, to: PageCellData, direction: DropData.Direction) -> Bool {
        guard let homeBlockId = MiddlewareConfiguration.shared?.homeBlockID else {
            anytypeAssertionFailure("Shared configuration is nil")
            return false
        }
        
        objectActionsService.move(
            dashboadId: homeBlockId,
            blockId: from.id,
            dropPositionblockId: to.id,
            position: direction.toBlockModel()
        )
        
        return true
    }
}
