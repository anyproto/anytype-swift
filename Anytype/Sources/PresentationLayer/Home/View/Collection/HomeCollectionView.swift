import SwiftUI
import UniformTypeIdentifiers


struct HomeCollectionView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var cellData: [HomeCellData]
    let dragAndDropDelegate: DragAndDropDelegate?
    let offsetChanged: (CGPoint) -> Void
    let onTap: (HomeCellData) -> Void
    
    @State private var dropData = DropData()
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
    }
    
    private var content: some View {
        OffsetAwareScrollView(showsIndicators: false, offsetChanged: offsetChanged) {
            LazyVGrid(columns: columns) {
                ForEach(cellData) { data in
                    Button(
                        action: { onTap(data) },
                        label: {
                            HomeCell(
                                cellData: data,
                                selected: viewModel.selectedPageIds.contains(data.id)
                            )
                        }
                    )
                    .disabled(data.isLoading)
                    
                    .ifLet(dragAndDropDelegate) { view, delegate in
                        view.onDrag {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            dropData.draggingCellData = data
                            return NSItemProvider(object: data.id as NSString)
                        }
                        .onDrop(
                            of: [UTType.text],
                            delegate: HomeCollectionDropInsideDelegate(dragAndDropDelegate: delegate, delegateData: data, cellData: cellData, data: $dropData)
                        )
                    }
                }
            }
            .padding()
        }
        .padding([.top], -22)
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView(cellData: [], dragAndDropDelegate: HomeViewModel(), offsetChanged: { _ in }, onTap: { _ in })
    }
}
