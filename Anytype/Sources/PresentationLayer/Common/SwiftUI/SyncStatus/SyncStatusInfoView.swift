import SwiftUI


struct SyncStatusInfoView: View {
    @StateObject private var model: SyncStatusInfoViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: SyncStatusInfoViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            networkInfo
        }
        .padding(8)
        .cornerRadius(16, style: .continuous)
        .background(Color.Background.secondary)
    }
    
    
    // Temporary design
    var networkInfo: some View {
        HStack(spacing: 0) {
            AnytypeText("Sync status: \(model.syncStatus)", style: .uxTitle2Regular)
                .padding()
        }.padding(.horizontal, 16)
    }
}

#Preview {
    SyncStatusInfoView(spaceId: "")
}
