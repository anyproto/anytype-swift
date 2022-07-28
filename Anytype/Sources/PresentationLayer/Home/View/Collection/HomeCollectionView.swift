import SwiftUI
import UniformTypeIdentifiers
import AnytypeCore

struct HomeCollectionView: View {
    private let columns: [GridItem] = {
        if UIDevice.isPad {
            return [GridItem(.adaptive(minimum: 150))]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }()
    
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
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(cellData) { data in
                    HomeCell(
                        cellData: data,
                        selected: viewModel.selectedPageIds.contains(data.id)
                    )
                    .onTapGesture { onTap(data) }
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
                    .if(!data.isArchived) {
                        $0.contextMenu {
                            HomeContextMenuView(cellData: data)
                        }
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
        HomeCollectionView(cellData: [], dragAndDropDelegate: HomeViewModel.makeForPreview(), offsetChanged: { _ in }, onTap: { _ in })
    }
}
