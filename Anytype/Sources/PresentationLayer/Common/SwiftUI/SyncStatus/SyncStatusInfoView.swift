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
        .animation(.default, value: model.syncStatusInfo)
    }
    
    var networkInfo: some View {
        HStack(spacing: 12) {
            networkIcon
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.syncStatusInfo.networkTitle, style: .uxTitle2Regular)
                    .lineLimit(1)
                AnytypeText(model.syncStatusInfo?.networkSubtitle, style: .relation3Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    var networkIcon: some View {
        ZStack {
            Circle().frame(width: 48, height: 48).foregroundStyle(model.syncStatusInfo.networkIconColor)
            Image(asset: model.syncStatusInfo.networkIcon).frame(width: 32, height: 32)
        }
        .transition(.opacity)
    }
}


import Services

#Preview("Anytype network") {
    MockView { } content: {
        SyncStatusInfoView(spaceId: "")
    }
}

#Preview("Self host") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = SyncStatusInfo.mockArray(network: .selfHost)
    } content: {
        SyncStatusInfoView(spaceId: "")
    }
}

#Preview("Local only") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = SyncStatusInfo.mockArray(network: .localOnly)
    } content: {
        SyncStatusInfoView(spaceId: "")
    }
}
