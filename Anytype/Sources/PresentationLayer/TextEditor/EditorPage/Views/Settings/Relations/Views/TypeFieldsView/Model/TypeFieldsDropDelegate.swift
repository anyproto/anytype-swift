import SwiftUI


struct TypeFieldsDropDelegate: DropDelegate {
    let destinationRow: TypeFieldsRow
    let document: any BaseDocumentProtocol
    
    @Binding var draggedRow: TypeFieldsRow?
    @Binding var allRows: [TypeFieldsRow]
    
    private let moveHandler = TypeFieldsMoveHandler()
    
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
