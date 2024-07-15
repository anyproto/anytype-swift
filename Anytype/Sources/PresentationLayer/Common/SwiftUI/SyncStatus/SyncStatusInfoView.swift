import SwiftUI


struct SyncStatusInfoView: View {
    @StateObject private var model: SyncStatusInfoViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: SyncStatusInfoViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            networkInfo.newDivider()
            p2pInfo
        }
        .padding(8)
        .cornerRadius(16, style: .continuous)
        .background(Color.Background.secondary)
        .animation(.default, value: model.syncStatusInfo)
    }
    
    var networkInfo: some View {
        HStack(alignment: .center, spacing: 12) {
            NetworkIconView(iconProvider: $model.syncStatusInfo)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.syncStatusInfo.networkTitle, style: .uxTitle2Regular)
                    .lineLimit(1)
                if model.syncStatusInfo.networkSubtitle.isNotEmpty {
                    AnytypeText(model.syncStatusInfo.networkSubtitle, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    var p2pInfo: some View {
        HStack(alignment: .center, spacing: 12) {
            NetworkIconView(iconProvider: $model.p2pStatusInfo)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.p2pStatusInfo.networkTitle, style: .uxTitle2Regular)
                    .lineLimit(1)
                if model.p2pStatusInfo.networkSubtitle.isNotEmpty {
                    AnytypeText(model.p2pStatusInfo.networkSubtitle, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


import Services

#Preview("Anytype network") {
    MockView { } content: {
        SyncStatusInfoView(spaceId: "")
    }
}

#Preview("Syncing state") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = [.mock(status: .syncing)]
    } content: {
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
