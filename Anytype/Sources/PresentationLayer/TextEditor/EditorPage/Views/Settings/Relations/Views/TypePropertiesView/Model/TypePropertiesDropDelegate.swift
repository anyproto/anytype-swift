import SwiftUI


struct TypePropertiesDropDelegate: DropDelegate {
    let destinationRow: TypePropertiesRow
    let document: any BaseDocumentProtocol
    
    @Binding var draggedRow: TypePropertiesRow?
    @Binding var allRows: [TypePropertiesRow]
    
    private let moveHandler = TypePropertiesMoveHandler()
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedRow = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedRow else { return }
        guard let fromIndex = allRows.firstIndex(of: draggedRow) else { return }
        guard let toIndex = allRows.firstIndex(of: destinationRow) else { return }
        
        Task {
            try await moveHandler.onMove(
                from: fromIndex,
                to: toIndex,
                relationRows: allRows,
                document: document
            )
        }
    }

}
