import SwiftUI
import Services

struct SwiftUIEditorSyncStatusItem: UIViewRepresentable {
    let statusData: SyncStatusData?
    let onTap: () -> ()

    func makeUIView(context: Context) -> EditorSyncStatusItem {
        EditorSyncStatusItem(statusData: statusData, onTap: onTap)
    }

    func updateUIView(_ item: EditorSyncStatusItem, context: Context) {
        item.changeStatusData(statusData)
    }
}

private struct SwiftUIEditorSyncStatusItemPreviewView: View {
    let status: SpaceSyncStatus
    let networkId: String

    var body: some View {
        SwiftUIEditorSyncStatusItem(
            statusData: SyncStatusData(status: status, networkId: networkId, isHidden: false),
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
