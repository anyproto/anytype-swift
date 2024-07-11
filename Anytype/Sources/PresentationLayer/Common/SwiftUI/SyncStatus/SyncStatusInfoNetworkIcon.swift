import SwiftUI
import Services


struct SyncStatusInfoNetworkIcon: View {
    @State private var color: Color
    @ObservedObject var model: SyncStatusInfoViewModel
    
    init(model: SyncStatusInfoViewModel) {
        self.color = model.syncStatusInfo.networkIconColor.initialColor
        self.model = model
    }
    
    var body: some View {
        ZStack {
            Circle().frame(width: 48, height: 48)
                .foregroundStyle(color)
            Image(asset: model.syncStatusInfo.networkIcon).frame(width: 32, height: 32)
        }
        .onAppear {
            updateColor()
        }
        .onChange(of: model.syncStatusInfo.networkIconColor) { _ in
            updateColor()
        }
        .transition(.opacity)
        .animation(.default, value: model.syncStatusInfo)
    }
    
    private func updateColor() {
        color = model.syncStatusInfo.networkIconColor.initialColor
        
        if case let .animation(_, end) = model.syncStatusInfo.networkIconColor {
            withAnimation(.smooth(duration: 1).repeatForever()) {
                color = end
            }
        }
    }
}


#Preview("Syncing state") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = [.mock(status: .syncing)]
    } content: {
        SyncStatusInfoNetworkIcon(
            model: SyncStatusInfoViewModel(spaceId: "")
        )
    }
}
