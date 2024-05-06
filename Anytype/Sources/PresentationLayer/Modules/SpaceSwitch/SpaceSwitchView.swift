import SwiftUI

struct SpaceSwitchView: View {
    
    private enum Constants {
        static let minExternalSpacing: CGFloat = 30
        static let maxInternalSpacing: CGFloat = 21
        static let itemWidth: CGFloat = SpaceRowView.width
    }
    
    @StateObject private var model: SpaceSwitchViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var headerSize: CGSize = .zero
    @State private var size: CGSize = .zero
    
    init(output: SpaceSwitchModuleOutput?) {
        _model = StateObject(wrappedValue: SpaceSwitchViewModel(output: output))
    }
    
    private var columns: [GridItem] {
        let freeSizeForContent = size.width - Constants.minExternalSpacing * 2
        let count = calculateCountItems(itemSize: Constants.itemWidth, spacing: Constants.maxInternalSpacing, freeWidth: freeSizeForContent)
        let freeSizeForSpacing = freeSizeForContent - Constants.itemWidth * CGFloat(count) - Constants.maxInternalSpacing * CGFloat(count - 1)
        let additionalSpacing = freeSizeForSpacing / CGFloat(count + 1)
        let item = GridItem(.fixed(Constants.itemWidth), spacing:  Constants.maxInternalSpacing + additionalSpacing, alignment: .top)
        return Array(repeating: item, count: count)
    }
    
    var body: some View {
        if #available(iOS 16.4, *) {
            contentContainer
                .presentationDetents([.height(380), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(16)
        } else {
            contentContainer
                .presentationDetents([.height(380), .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var contentContainer: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { reader in
                VerticalScrollViewWithOverlayHeader {
                    Color.clear
                        .frame(height: headerSize.height)
                        .background(Color.ModalScreen.backgroundWithBlur)
                        .background(.ultraThinMaterial)
                } content: {
                    content
                }
                .scrollIndicators(.never)
                .onChange(of: model.scrollToRowId) { rowId in
                    reader.scrollTo(rowId)
                }
            }
            header
                .readSize { size in
                    headerSize = size
                }
        }
        .background(Color.ModalScreen.backgroundWithBlur)
        .background(.ultraThinMaterial)
        .disablePresentationBackground()
        .readSize { newSize in
            self.size = newSize
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .anytypeSheet(item: $model.spaceViewForDelete) { space in
            SpaceDeleteAlert(spaceId: space.targetSpaceId)
        }
        .anytypeSheet(item: $model.spaceViewForLeave) { space in
            SpaceLeaveAlert(spaceId: space.targetSpaceId)
        }
        .anytypeSheet(item: $model.spaceViewStopSharing) { space in
            StopSharingAlert(spaceId: space.targetSpaceId)
         }
    }
    
    private var content: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(model.rows, id: \.id) { row in
                SpaceRowView(model: row)
                    .id(row.id)
            }
            if model.createSpaceAvailable {
                SpacePlusRow() {
                    model.onAddSpaceTap()
                }
            }
        }
        .padding([.top], headerSize.height + 6)
    }

    private var header: some View {
        HStack(spacing: 0) {
            IconView(icon: model.profileIcon)
                .frame(width: 32, height: 32)
            Spacer.fixedWidth(12)
            AnytypeText(model.profileName, style: .heading)
                .foregroundColor(.Text.white)
                .lineLimit(1)
            Spacer()
            Image(asset: .NavigationBase.settings)
                .foregroundColor(.Button.white)
        }
        .frame(height: 68)
        .fixTappableArea()
        .onTapGesture {
            model.onProfileTap()
        }
        .padding(.horizontal, Constants.minExternalSpacing)
    }
    
    private func calculateCountItems(itemSize: CGFloat, spacing: CGFloat, freeWidth: CGFloat) -> Int {
        if itemSize + spacing < freeWidth {
            return calculateCountItems(itemSize: itemSize, spacing: spacing, freeWidth: freeWidth - itemSize - spacing) + 1
        } else if itemSize <= freeWidth {
            return 1
        } else {
            return 0
        }
    }
}

#Preview {
    MockView {
        SpaceSwitchView(output: nil)
    }
}
