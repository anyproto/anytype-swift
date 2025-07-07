import SwiftUI
import Services

struct SwiftUIEditorSyncStatusItem: UIViewRepresentable {
    let statusData: SyncStatusData?
    let itemState: EditorBarItemState
    let onTap: () -> ()
    
    func makeUIView(context: Context) -> EditorSyncStatusItem {
        EditorSyncStatusItem(statusData: statusData, itemState: itemState, onTap: onTap)
    }
    
    func updateUIView(_ item: EditorSyncStatusItem, context: Context) {
        item.changeStatusData(statusData)
        item.changeItemState(itemState)
    }
}

private struct SwiftUIEditorSyncStatusItemPreviewView: View {
    let status: SpaceSyncStatus
    let networkId: String
    
    var body: some View {
        SwiftUIEditorSyncStatusItem(
            statusData: SyncStatusData(status: status, networkId: networkId, isHidden: false),
            itemState: .initial,
            onTap: {}
        )
    }
}

#Preview {
    
    return VStack {
        ForEach(SpaceSyncStatus.allCases, id:\.self) {
            SwiftUIEditorSyncStatusItemPreviewView(status: $0, networkId: "1337")
                .padding()
            Divider()
        }
        
        SwiftUIEditorSyncStatusItemPreviewView(status: .offline, networkId: "")
    }
}
