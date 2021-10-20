import Foundation
import AnytypeCore
import SwiftUI

// MARK: - CellDataManager
protocol DragAndDropDelegate {
    func onDrag(from: HomeCellData, to: HomeCellData) -> DropData.Direction?
    func onDrop(from: HomeCellData, to: HomeCellData, direction: DropData.Direction) -> Bool
}

// Drag and drop only for favorites
extension HomeViewModel: DragAndDropDelegate {
    func onDrag(from: HomeCellData, to: HomeCellData) -> DropData.Direction? {
        guard from.id != to.id else {
            return nil
        }
        
        guard let fromIndex = favoritesCellData.index(id: from.id),
              let toIndex = favoritesCellData.index(id: to.id) else {
            return nil
        }
        
        let dropAfter = toIndex > fromIndex
        
        withAnimation(.spring()) {
            favoritesCellData.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: dropAfter ? toIndex + 1 : toIndex
            )
        }
        
        return dropAfter ? .after : .before
    }
    
    func onDrop(from: HomeCellData, to: HomeCellData, direction: DropData.Direction) -> Bool {
        guard let homeBlockId = MiddlewareConfigurationService.shared.configuration()?.homeBlockID else {
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
