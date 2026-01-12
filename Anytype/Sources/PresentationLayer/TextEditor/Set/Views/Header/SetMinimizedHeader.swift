import SwiftUI
import AnytypeCore

struct SetMinimizedHeader: View {

    @Environment(\.widgetsAnimationNamespace) private var widgetsNamespace
    @Namespace private var glassNamespace

    @ObservedObject var model: EditorSetViewModel
    var headerSize: CGSize
    var tableViewOffset: CGPoint
    @Binding var headerMinimizedSize: CGSize

    private let height = ObjectHeaderConstants.minimizedHeaderHeight

    var body: some View {
        VStack {
            header
            Spacer()
        }
    }

    private var header: some View {
        GlassEffectContainerIOS26(spacing: 12) {
            HStack(spacing: 8) {
                PageNavigationBackButton()
                titlePill

                HStack(spacing: 8) {
                    syncsStatusButton
                    if !model.hasTargetObjectId {
                        settingsButton
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: height)
        .readSize { headerMinimizedSize = $0 }
    }

    private var titlePill: some View {
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
        .matchedTransitionSourceIOS26(id: "widgetsOverlay", in: widgetsNamespace)
        .glassEffectInteractiveIOS26(in: Capsule())
        .glassEffectIDIOS26("titlePill", in: glassNamespace)
    }

    private var syncsStatusButton: some View {
        Button {
            model.showSyncStatusInfo()
        } label: {
            SwiftUIEditorSyncStatusItem(
                statusData: model.syncStatusData,
                itemState: .initial,
                onTap: {}
            )
            .frame(width: 28, height: 28)
            .allowsHitTesting(false)
        }
        .frame(width: 44, height: 44)
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("syncStatus", in: glassNamespace)
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
                        .frame(width: 44, height: 44)
                }
            } else {
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    model.showObjectSettings()
                } label: {
                    Image(asset: .X24.more)
                        .foregroundStyle(Color.Control.primary)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("settings", in: glassNamespace)
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
