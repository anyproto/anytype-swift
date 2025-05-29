import SwiftUI
import AnytypeCore

struct SetMinimizedHeader: View {
    
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
        VStack(spacing: 0) {
            NavigationHeaderContainer(spacing: 0) {
                PageNavigationBackButton()
            } titleView: {
                title
            } rightView: {
                HStack(spacing: 12) {
                    syncsStatusItem
                    if !model.hasTargetObjectId {
                        settingsButton
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 2)
        }
        .frame(height: height)
        .background(Color.Background.primary.opacity(opacity))
        .readSize { headerMinimizedSize = $0 }
    }
    
    private var title: some View {
        HStack(spacing: 8) {
            if let icon = model.details?.objectIconImage {
                IconView(icon: icon)
                    .frame(width: 18, height: 18)
            }
            model.details.flatMap {
                AnytypeText($0.pluralTitle, style: .bodyRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
            }
        }
        .opacity(titleOpacity)
        .frame(maxWidth: .infinity).layoutPriority(1)
    }
    
    private var syncsStatusItem: some View {
        SwiftUIEditorSyncStatusItem(
            statusData: model.syncStatusData,
            itemState: EditorBarItemState(
                haveBackground: model.details?.documentCover.isNotNil ?? false,
                opacity: opacity
            ),
            onTap: {
                model.showSyncStatusInfo()
            }
        )
        .frame(width: 28, height: 28)
    }
    
    private var settingsButton: some View {
        EditorBarButtonItem(
            imageAsset: .X24.more,
            state: EditorBarItemState(
                haveBackground: model.details?.documentCover.isNotNil ?? false,
                opacity: opacity
            ),
            action: {
                UISelectionFeedbackGenerator().selectionChanged()
                model.showObjectSettings()
            }
        )
        .frame(width: 44, height: 44)
    }

    private var opacity: Double {
        guard tableViewOffset.y < 0 else { return 0 }

        let startingOpacityHeight = headerSize.height - height
        let opacity = abs(tableViewOffset.y) / startingOpacityHeight
        return min(opacity, 1)
    }
    
    private var titleOpacity: Double {
        (max(opacity, 0.5) - 0.5) * 2
    }
    
    private var syncStatusItemOpacity: Double {
        min(opacity, 0.5) * 2
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
