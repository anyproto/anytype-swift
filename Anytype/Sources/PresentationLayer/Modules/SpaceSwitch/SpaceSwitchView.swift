import SwiftUI

struct SpaceSwitchView: View {
    
    @StateObject var model: SpaceSwitchViewModel
    
    @State private var headerSize: CGSize = .zero
    
    private let columns = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
    ]
    
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
        .padding([.top], headerSize.height + 14)
        .animation(.default, value: model.rows.count)
    }

    private var header: some View {
        VStack {
            DragIndicator()
            HStack {
                Spacer()
                AnytypeText(model.profileName, style: .heading, color: .Text.white)
                Spacer()
            }
            .overlay(rightButton, alignment: .trailing)
            .frame(height: 48)
            .padding(.horizontal, 16)
        }
    }
    
    private var rightButton: some View {
        Button {
            model.onTapProfile()
        } label: {
            IconView(icon: model.profileIcon)
                .frame(width: 32, height: 32)
        }
    }
}

