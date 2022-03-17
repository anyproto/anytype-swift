import SwiftUI

struct SetMinimizedHeader: View {
    var headerSize: CGSize
    var tableViewOffset: CGPoint
    @Binding var headerMinimizedSize: CGSize

    @EnvironmentObject private var model: EditorSetViewModel

    private let minimizedHeaderHeight = ObjectHeaderConstants.minimizedHeaderHeight + UIApplication.shared.mainWindowInsets.top

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
                Rectangle().frame(width: 1, height: 1).foregroundColor(.clear) // sync status here
                Spacer()
                title
                Spacer()
                settingsButton
            }
            .padding(.horizontal, 10)
        }
        .frame(height: minimizedHeaderHeight)
        .background(Color.backgroundPrimary.opacity(opacity))
        .readSize { headerMinimizedSize = $0 }
    }
    
    private var title: some View {
        Group {
            if let icon = model.details.objectIconImage {
                SwiftUIObjectIconImageView(iconImage: icon, usecase: .openedObjectNavigationBar)
                    .frame(width: 18, height: 18)
                Spacer.fixedWidth(8)
            }
            AnytypeText(model.details.title, style: .body, color: .textPrimary)
                .lineLimit(1)
        }
        .opacity(opacity)
    }
    
    private var settingsButton: some View {
        EditorBarButtonItem(
            image: .more,
            state: EditorBarItemState(
                haveBackground: model.details.documentCover.isNotNil,
                opacity: opacity
            ),
            action: model.onSettingsTap
        )
        .frame(width: 28, height: 28)
    }

    private var opacity: Double {
        guard tableViewOffset.y < 0 else { return 0 }

        let startingOpacityHeight = headerSize.height - minimizedHeaderHeight
        let opacity = abs(tableViewOffset.y) / startingOpacityHeight
        return min(opacity, 1)
    }
}


struct SetMinimizedHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetMinimizedHeader(
            headerSize: .init(width: 100, height: 200),
            tableViewOffset: .zero,
            headerMinimizedSize: .constant(.zero)
        )
    }
}
