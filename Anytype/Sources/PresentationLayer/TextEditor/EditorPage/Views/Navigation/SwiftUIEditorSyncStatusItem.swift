import SwiftUI
import Services

struct SwiftUIEditorSyncStatusItem: UIViewRepresentable {
    let statusData: SyncStatusData
    let state: EditorBarItemState
    
    func makeUIView(context: Context) -> EditorSyncStatusItem {
        EditorSyncStatusItem(statusData: statusData)
    }
    
    func updateUIView(_ item: EditorSyncStatusItem, context: Context) {
        item.changeState(state)
        item.changeStatusData(statusData)
    }
}
