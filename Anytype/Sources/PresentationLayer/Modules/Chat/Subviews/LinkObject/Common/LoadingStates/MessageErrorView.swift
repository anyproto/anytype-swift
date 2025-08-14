import SwiftUI
import Services

struct MessageErrorView: View {
    
    let syncError: SyncError?
    
    @State private var showVersionAlert = false
    @State private var showNetworkAlert = false
    
    var body: some View {
        Button {
            switch syncError {
            case .incompatibleVersion:
                showVersionAlert = true
            case .networkError:
                showNetworkAlert = true
            default:
                break
            }
        } label: {
            MessageLoadingStateContainer {
                Image(asset: .FileTypes.WithoutIcon.error)
                    .resizable()
                    .foregroundStyle(Color.Control.white)
            }
            .background(.black.opacity(0.5))
        }
        .buttonStyle(StandardPlainButtonStyle())
        .anytypeSheet(isPresented: $showVersionAlert) {
            MessageIncompatibleVersionErrorAlert()
        }
        .anytypeSheet(isPresented: $showNetworkAlert) {
            MessageNetworkErrorAlert()
        }
    }
}

#Preview {
    MessageErrorView(syncError: .incompatibleVersion)
        .frame(width: 48, height: 48)
    MessageErrorView(syncError: .oversized)
        .frame(width: 100, height: 100)
    MessageErrorView(syncError: nil)
        .frame(width: 100, height: 100)
}
