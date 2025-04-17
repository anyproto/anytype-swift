import SwiftUI

struct ObjectSettingsResolveConflictAlert: View {
    
    @Environment(\.dismiss) private var dismiss
    private let onResolve: () async throws -> Void
    
    init(onResolve: @escaping () async throws -> Void) {
        self.onResolve = onResolve
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.resolveLayoutConflict,
            message: Loc.Primitives.LayoutConflict.description,
            buttons: {
                BottomAlertButton(
                    text: Loc.resetToDefault,
                    style: .primary
                ) {
                    try await onResolve()
                    dismiss()
                }
                
                BottomAlertButton(
                    text: Loc.cancel,
                    style: .secondary
                ) {
                    dismiss()
                }
            }
        )
    }
}
