import SwiftUI
import AnytypeCore

struct SetMinimizedHeader: View {

    @Namespace private var rightContentGlassNamespace

    @ObservedObject var model: EditorSetViewModel
    var headerSize: CGSize
    var tableViewOffset: CGPoint
    @Binding var headerMinimizedSize: CGSize

    var body: some View {
        VStack {
            header
            Spacer()
        }
    }

    private var header: some View {
        NavigationHeader(
            navigationButtonType: .back,
            isTitleInteractive: true
        ) {
            titleContent
        } rightContent: {
            HStack(spacing: 8) {
                syncsStatusButton
                if !model.hasTargetObjectId {
                    settingsButton
                }
            }
        }
        .readSize { headerMinimizedSize = $0 }
    }

    private var titleContent: some View {
        Button {
            model.onTapWidgets()
        } label: {
            HStack(spacing: 8) {
                if let icon = model.details?.objectIconImage {
                    IconView(icon: icon)
                        .frame(width: 18, height: 18)
                }
                model.details.flatMap {
                    AnytypeText($0.pluralTitle, style: .uxTitle1Semibold)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var syncsStatusButton: some View {
        Button {
            model.showSyncStatusInfo()
        } label: {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
                onTap: {}
            )
            .frame(width: 28, height: 28)
            .allowsHitTesting(false)
        }
        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("syncStatus", in: rightContentGlassNamespace)
    }

    @ViewBuilder
    private var settingsButton: some View {
        Group {
            if FeatureFlags.newObjectSettings {
                ObjectSettingsMenuContainer(
                    objectId: model.setDocument.objectId,
                    spaceId: model.setDocument.spaceId,
                    output: model.headerSettingsViewModel.output
                ) {
                    Image(asset: .X24.more)
                        .foregroundStyle(Color.Control.primary)
                        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                }
            } else {
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    model.showObjectSettings()
                } label: {
                    Image(asset: .X24.more)
                        .foregroundStyle(Color.Control.primary)
                        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                }
            }
        }
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("settings", in: rightContentGlassNamespace)
    }
}


struct SetMinimizedHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetMinimizedHeader(
            model: EditorSetViewModel.emptyPreview,
            headerSize: .init(width: 100, height: 200),
            tableViewOffset: .zero,
            headerMinimizedSize: .constant(.zero)
        )
    }
}
