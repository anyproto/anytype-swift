import SwiftUI

struct TypeDeleteAlert: View {
    
    @Environment(\.dismiss) private var dismiss
    private let onDelete: () async throws -> Void
    
    init(onDelete: @escaping () async throws -> Void) {
        self.onDelete = onDelete
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.areYouSure,
            message: Loc.theseObjectsWillBeDeletedIrrevocably,
            buttons: {
                BottomAlertButton(
                    text: Loc.cancel,
                    style: .secondary
                ) {
                    dismiss()
                }
                
                BottomAlertButton(
                    text: Loc.delete,
                    style: .warning
                ) {
                    try await onDelete()
                }
            }
        )
    }
}
