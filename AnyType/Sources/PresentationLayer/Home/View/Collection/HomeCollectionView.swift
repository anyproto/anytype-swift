import SwiftUI
import UniformTypeIdentifiers


struct HomeCollectionView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var cellData: [PageCellData]
    let coordinator: HomeCoordinator
    let cellDataManager: PageCellDataManager
    let offsetChanged: (CGPoint) -> Void
    
    @State private var dropData = DropData()
    
    var body: some View {
        OffsetAwareScrollView(offsetChanged: offsetChanged) {
            LazyVGrid(columns: columns) {
                ForEach(cellData) { data in
                    NavigationLink(
                        destination: coordinator.documentView(
                            selectedDocumentId: data.destinationId
                        ),
                        label: {
                            PageCell(cellData: data)
                                .cornerRadius(16)
                                .frame(idealHeight: 124)
                        }
                    )
                    .disabled(data.isLoading)
                    .onDrag {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        dropData.draggingCellData = data
                        return NSItemProvider(object: data.id as NSString)
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: HomeCollectionDropInsideDelegate(cellDataManager: cellDataManager, delegateData: data, cellData: cellData, data: $dropData)
                    )
                }
            }
            .padding()
        }
        .animation(.spring())
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView(cellData: [], coordinator: ServiceLocator.shared.homeCoordinator(), cellDataManager: HomeViewModel(), offsetChanged: { _ in })
    }
}
