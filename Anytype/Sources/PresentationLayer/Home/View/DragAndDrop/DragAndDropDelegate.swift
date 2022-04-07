import Foundation
import AnytypeCore
import SwiftUI
import Amplitude

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
        let homeBlockId = MiddlewareConfigurationProvider.shared.configuration.homeBlockID
        
        objectActionsService.move(
            dashboadId: homeBlockId,
            blockId: from.id,
            dropPositionblockId: to.id,
            position: direction.toBlockModel()
        )

        Amplitude.instance().logEvent(
            AmplitudeEventsName.reorderObjects,
            withEventProperties: [AmplitudeEventsPropertiesKey.route: AmplitudeEventsName.homeShow]
        )
        
        return true
    }
}
