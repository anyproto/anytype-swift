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
        .cornerRadius(16, style: .continuous)
        .background(Color.Background.secondary)
        .animation(.default, value: model.syncStatusInfo)
    }
    
    var networkInfo: some View {
        Button {
            model.onNetworkInfoTap()
        } label: {
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
                if model.syncStatusInfo.haveTapIndicatior {
                    Image(asset: .X18.webLink).foregroundColor(.Text.tertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .disabled(!model.syncStatusInfo.haveTapIndicatior)
    }
    
    var p2pInfo: some View {
        Button {
            model.onP2PTap()
        } label: {
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
                if model.p2pStatusInfo.haveTapIndicatior {
                    Image(asset: .X18.webLink).foregroundColor(.Text.tertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }.disabled(!model.p2pStatusInfo.haveTapIndicatior)
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
        SyncStatusStorageMock.shared.infoToReturn = SpaceSyncStatusInfo.mockArray(network: .selfHost)
    } content: {
        SyncStatusInfoView(spaceId: "")
    }
}

#Preview("Local only") {
    MockView {
        SyncStatusStorageMock.shared.infoToReturn = SpaceSyncStatusInfo.mockArray(network: .localOnly)
    } content: {
        SyncStatusInfoView(spaceId: "")
    }
}
