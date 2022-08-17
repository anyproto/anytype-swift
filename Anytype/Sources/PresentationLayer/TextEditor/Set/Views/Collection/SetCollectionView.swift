import SwiftUI

struct SetCollectionView: View {
    @ObservedObject private(set) var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    
    var headerMinimizedSize: CGSize

    var body: some View {
        OffsetAwareScrollView(
            axes: [.vertical],
            showsIndicators: false,
            offsetChanged: { offset.y = $0.y }
        ) {
            Spacer.fixedHeight(tableHeaderSize.height)
            LazyVGrid(
                columns: columns(),
                alignment: .center,
                spacing: SetCollectionView.interCellSpacing,
                pinnedViews: [.sectionHeaders])
            {
                content
            }
            .padding(.top, -headerMinimizedSize.height)
            .padding(.horizontal, 10)
            pagination
        }
        .overlay(
            SetFullHeader()
                .readSize { tableHeaderSize = $0 }
                .offset(x: 0, y: offset.y)
            , alignment: .topLeading
        )
    }
    
    private var content: some View {
        Group {
            if model.isEmpty {
                EmptyView()
            } else {
                Section(header: compoundHeader) {
                    ForEach(model.configurations) { configuration in
                        SetCollectionViewCell(configuration: configuration)
                    }
                }
            }
        }
    }
    
    private var pagination: some View {
        EditorSetPaginationView()
            .frame(width: tableHeaderSize.width)
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                HStack {
                    SetHeaderSettings()
                        .environmentObject(model)
                        .frame(width: tableHeaderSize.width)
                        .offset(x: 4, y: 8)
                    Spacer()
                }
            }
        }
        .background(Color.backgroundPrimary)
    }
    
    private func columns() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: SetCollectionView.interCellSpacing, alignment: .topLeading),
            count: model.isSmallItemSize ? 2 : 1
        )
    }
}

extension SetCollectionView {
    static let interCellSpacing: CGFloat = 11
}

struct SetCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        SetCollectionView(
            model: EditorSetViewModel.empty,
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

