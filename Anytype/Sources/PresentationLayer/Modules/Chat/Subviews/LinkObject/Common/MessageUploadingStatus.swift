import SwiftUI
import Services

struct MessageUploadingStatus: View {
    
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    var body: some View {
        switch syncStatus {
        case .synced, .UNRECOGNIZED, .none:
            EmptyView()
        case .syncing, .queued:
            MessageCircleLoadingView()
                .frame(width: 52, height: 52)
        case .error:
            Image(asset: .Dialog.exclamation)
                .resizable()
                .frame(width: 52, height: 52)
        }
    }
}
