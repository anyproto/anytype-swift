import SwiftUI

struct SpaceSwitchView: View {
    
    private enum Constants {
        static let minExternalSpacing: CGFloat = 30
        static let maxInternalSpacing: CGFloat = 21
        static let itemWidth: CGFloat = SpaceRowView.width
    }
    
    @StateObject var model: SpaceSwitchViewModel
    
    @State private var headerSize: CGSize = .zero
    @State private var spacingBetweenItems: CGFloat = 0
    @State private var externalSpacing: CGFloat = 0
    
    private var columns: [GridItem] {
        [
            GridItem(.fixed(Constants.itemWidth), spacing: spacingBetweenItems, alignment: .top),
            GridItem(.fixed(Constants.itemWidth), spacing: spacingBetweenItems, alignment: .top),
            GridItem(.fixed(Constants.itemWidth), spacing: spacingBetweenItems, alignment: .top)
        ]
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            contentContainer
                .presentationDetents([.height(380), .large])
                .presentationDragIndicator(.hidden)
                .presentationBackgroundLegacy(.ultraThinMaterial)
                .presentationCornerRadiusLegacy(16)
        } else {
            contentContainer
        }
    }
    
    private var contentContainer: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { reader in
                VerticalScrollViewWithOverlayHeader {
                    Color.clear
                        .frame(height: headerSize.height)
                        .background(Color.Background.material)
                        .background(.ultraThinMaterial)
                } content: {
                    content
                }
                .hideScrollIndicatorLegacy()
                .onChange(of: model.scrollToRowId) { rowId in
                    reader.scrollTo(rowId)
                }
            }
            header
                .readSize { size in
                    headerSize = size
                }
        }
        .background(Color.Background.material)
        .readSize { newSize in
            let allSpacing = newSize.width - CGFloat(columns.count) * Constants.itemWidth
            let countBetweenSpacing = CGFloat(columns.count - 1)
            let freeSpacing = max(allSpacing - Constants.minExternalSpacing * 2, 0)
            let preferredSpacingBetweenItems = freeSpacing * (1 / countBetweenSpacing)
            let spacingBetweenItems = min(preferredSpacingBetweenItems, Constants.maxInternalSpacing)
            let externalSpacing = (allSpacing - spacingBetweenItems * countBetweenSpacing) * 0.5
            self.spacingBetweenItems = spacingBetweenItems
            self.externalSpacing = externalSpacing
        }
    }
    
    private var content: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(model.rows, id: \.id) { row in
                SpaceRowView(model: row)
                    .id(row.id)
            }
            SpacePlusRow(loading: model.spaceCreateLoading) {
                model.onTapAddSpace()
            }
        }
        .padding([.top], headerSize.height + 6)
        .animation(.default, value: model.rows.count)
    }

    private var header: some View {
        HStack(spacing: 0) {
            IconView(icon: model.profileIcon)
                .frame(width: 32, height: 32)
            Spacer.fixedWidth(12)
            AnytypeText(model.profileName, style: .heading, color: .Text.labelInversion)
                .lineLimit(1)
            Spacer()
            Button {
                model.onTapProfile()
            } label: {
                Image(asset: .Dashboard.settings)
                    .foregroundColor(.Button.white)
            }
        }
        .frame(height: 68)
        .padding(.horizontal, externalSpacing)
    }
}

