import SwiftUI
import Services

struct MessageFileUploadingStatus: View {
    
    let icon: Icon?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    var body: some View {
        switch syncStatus {
        case .synced, .UNRECOGNIZED, .none:
            IconView(icon: icon)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
        case .syncing, .queued:
            container {
                MessageCircleLoadingView()
            }
        case .error:
            container {
                MessageErrorView(syncError: syncError)
            }
        }
    }
    
    private func container<V: View>(@ViewBuilder content: () -> V) -> some View {
        ZStack {
            content()
        }
        .frame(width: 48, height: 48)
        .objectIconCornerRadius()
    }
}
