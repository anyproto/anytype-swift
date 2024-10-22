import Foundation
import SwiftUI

struct ChatHeader: View {
    
    let syncStatusData: SyncStatusData
    let icon: Icon?
    let title: String
    let onSyncStatusTap: () -> Void
    let onSettingsTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            SwiftUIEditorSyncStatusItem(
                statusData: syncStatusData,
                itemState: EditorBarItemState(haveBackground: false, opacity: 0)
            )
            .frame(width: 28, height: 28)
            .onTapGesture {
                onSyncStatusTap()
            }
            
            titleView
            
            Image(asset: .X24.more)
                .onTapGesture {
                    onSettingsTap()
                }
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
    }
    
    private var titleView: some View {
        HStack(spacing: 8) {
            if let icon {
                IconView(icon: icon)
                    .frame(width: 18, height: 18)
            }
            AnytypeText(title, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity).layoutPriority(1)
    }
}
