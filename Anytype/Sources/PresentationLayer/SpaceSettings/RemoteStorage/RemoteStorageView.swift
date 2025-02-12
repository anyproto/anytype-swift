import SwiftUI
import AnytypeCore

struct RemoteStorageView: View {
    
    @StateObject private var model: RemoteStorageViewModel
    
    init(spaceId: String, output: (any RemoteStorageModuleOutput)?) {
        _model = StateObject(wrappedValue: RemoteStorageViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        content
            .onAppear {
                model.onAppear()
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.remoteStorage)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer.fixedHeight(10)
                    AnytypeText(model.spaceInstruction, style: .uxCalloutRegular)
                        .foregroundColor(.Text.primary)
                    if model.showGetMoreSpaceButton {
                        Spacer.fixedHeight(16)
                        StandardButton("\(MembershipConstants.membershipSymbol.rawValue) \(Loc.upgrade)", style: .upgradeBadge) {
                            model.onTapGetMoreSpace()
                        }
                    }
                    Spacer.fixedHeight(20)
                    AnytypeText(model.spaceUsed, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                    Spacer.fixedHeight(8)
                    RemoteStorageSegment(model: model.segmentInfo)
                    Spacer.fixedHeight(16)
                    StandardButton(Loc.FileStorage.cleanUpFiles, style: .secondarySmall) {
                        model.onTapManageFiles()
                    }
                }
                .padding(.horizontal, 20)
            }
            .if(!model.contentLoaded) {
                $0.redacted(reason: .placeholder)
                  .allowsHitTesting(false)
            }
        }
    }
}

#Preview("Default") {
    MockView {
        FileLimitsStorageMock.shared.nodeUsageMockedValue = .mock(
            bytesUsage: 400*MB,
            bytesLeft: 600*MB,
            bytesLimit: 1000*MB
        )
    } content: {
        RemoteStorageView(spaceId: "", output: nil)
    }
}

#Preview("> 70% storage consumed") {
    MockView {
        FileLimitsStorageMock.shared.nodeUsageMockedValue = .mock(
            bytesUsage: 800*MB,
            bytesLeft: 200*MB,
            bytesLimit: 1000*MB
        )
    } content: {
        RemoteStorageView(spaceId: "", output: nil)
    }
}

#Preview("Limits exceeded") {
    MockView {
        FileLimitsStorageMock.shared.nodeUsageMockedValue = .mock(
            bytesUsage: 1000*MB,
            bytesLeft: 0,
            bytesLimit: 1000*MB,
            localBytesUsage: 2000*MB
        )
    } content: {
        RemoteStorageView(spaceId: "", output: nil)
    }
}
