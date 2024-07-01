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

#Preview {
    return VStack {
        ForEach(SyncStatus.allCases, id:\.self) {
            mock(status: $0)
            Divider()
        }
        
        mock(status: .unknown, networkId: "")
    }
    
    func mock(status: SyncStatus, networkId: String = "1337") -> SwiftUIEditorSyncStatusItem {
        SwiftUIEditorSyncStatusItem(
            statusData: SyncStatusData(status: status, networkId: networkId, isHidden: false),
            state: .initial
        )
    }
}
