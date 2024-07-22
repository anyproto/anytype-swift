import SwiftUI
import Services

struct SwiftUIEditorSyncStatusItem: UIViewRepresentable {
    let statusData: SyncStatusData
    let itemState: EditorBarItemState
    
    func makeUIView(context: Context) -> EditorSyncStatusItem {
        EditorSyncStatusItem(statusData: statusData, itemState: itemState, onTap: {})
    }
    
    func updateUIView(_ item: EditorSyncStatusItem, context: Context) {
        item.changeStatusData(statusData)
        item.changeItemState(itemState)
    }
}

#Preview {
    return VStack {
        ForEach(SyncStatus.allCases, id:\.self) {
            mock(status: $0).padding()
            Divider()
        }
        
        mock(status: .offline, networkId: "")
    }
    
    func mock(status: SyncStatus, networkId: String = "1337") -> SwiftUIEditorSyncStatusItem {
        SwiftUIEditorSyncStatusItem(
            statusData: SyncStatusData(status: status, networkId: networkId, isHidden: false),
            itemState: EditorBarItemState(haveBackground: false, opacity: 0)
        )
    }
}
