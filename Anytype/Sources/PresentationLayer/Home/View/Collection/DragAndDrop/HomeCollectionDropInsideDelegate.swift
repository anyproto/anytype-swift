import SwiftUI


struct HomeCollectionDropInsideDelegate: DropDelegate {
    let dragAndDropDelegate: DragAndDropDelegate
    let delegateData: HomeCellData
    var cellData: [HomeCellData]
    @Binding var data: DropData
    
    func dropEntered(info: DropInfo) {
        guard let draggingCellData = data.draggingCellData else {
            return
        }
        
        guard let direction = dragAndDropDelegate.onDrag(from: draggingCellData, to: delegateData) else {
            return
        }
        
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        data.dropPositionCellData = delegateData
        data.direction = direction
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingCellData = data.draggingCellData,
              let dropPositionCellData = data.dropPositionCellData,
              let direction = data.direction else {
            return false
        }
        
        data.direction = nil
        data.draggingCellData = nil
        data.dropPositionCellData = nil
        
        return dragAndDropDelegate.onDrop(from: draggingCellData, to: dropPositionCellData, direction: direction)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
