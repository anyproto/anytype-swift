import SwiftUI
import AnytypeCore

struct SetMinimizedHeader: View {
    
    @ObservedObject var model: EditorSetViewModel
    var headerSize: CGSize
    var tableViewOffset: CGPoint
    @Binding var headerMinimizedSize: CGSize

    private let height = ObjectHeaderConstants.minimizedHeaderHeight + UIApplication.shared.mainWindowInsets.top

    var body: some View {
        VStack {
            header
            Spacer()
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(UIApplication.shared.mainWindowInsets.top)
            HStack(alignment: .center, spacing: 0) {
                syncsStatusItem
                Spacer.fixedWidth(14)
                title
                Spacer()
                if !model.hasTargetObjectId {
                    settingsButton
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, model.hasTargetObjectId ? 46 : 2)
        }
        .frame(height: height)
        .background(Color.Background.primary.opacity(opacity))
        .readSize { headerMinimizedSize = $0 }
    }
    
    private var title: some View {
        HStack(spacing: 8) {
            if let icon = model.details?.objectIconImage {
                SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObjectNavigationBar)
                    .frame(width: 18, height: 18)
            }
            model.details.flatMap {
                AnytypeText($0.title, style: .bodyRegular, color: .Text.primary)
                    .lineLimit(1)
            }
        }
        .opacity(titleOpacity)
        .frame(maxWidth: .infinity).layoutPriority(1)
    }
    
    private var syncsStatusItem: some View {
        SwiftUIEditorSyncStatusItem(
            status: model.syncStatus,
            state: EditorBarItemState(
                haveBackground: model.hasTargetObjectId ? false : model.details?.documentCover.isNotNil ?? false,
                opacity: syncStatusItemOpacity
            )
        )
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
