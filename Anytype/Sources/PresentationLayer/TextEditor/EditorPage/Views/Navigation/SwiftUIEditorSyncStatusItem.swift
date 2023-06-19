import SwiftUI
import Services

struct SwiftUIEditorSyncStatusItem: UIViewRepresentable {
    let status: SyncStatus
    let state: EditorBarItemState
    
    func makeUIView(context: Context) -> EditorSyncStatusItem {
        EditorSyncStatusItem(status: status)
    }
    
    func updateUIView(_ item: EditorSyncStatusItem, context: Context) {
        item.changeState(state)
        item.changeStatus(status)
    }
}
