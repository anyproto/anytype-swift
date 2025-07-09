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
                    .frame(width: 30, height: 30)
            }
        case .error:
            container {
                MessageErrorView()
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    private func container<V: View>(@ViewBuilder content: () -> V) -> some View {
        ZStack {
            content()
        }
        .frame(width: 48, height: 48)
        .background(Color.Shape.tertiary)
        .objectIconCornerRadius()
    }
}
