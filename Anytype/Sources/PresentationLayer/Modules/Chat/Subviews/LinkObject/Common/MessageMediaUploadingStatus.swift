import SwiftUI
import Services

struct MessageMediaUploadingStatus<Content: View>: View {
    
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    @ViewBuilder let synced: () -> Content
    
    var body: some View {
        switch syncStatus {
        case .synced, .UNRECOGNIZED, .none:
            synced()
        case .syncing, .queued:
            MessageCircleLoadingView()
        case .error:
            MessageErrorView(syncError: syncError)
        }
    }
}

extension MessageMediaUploadingStatus where Content == EmptyView {
    init(syncStatus: SyncStatus?, syncError: SyncError?) {
        self.init(
            syncStatus: syncStatus,
            syncError: syncError,
            synced: {
                EmptyView()
            }
        )
    }
}
