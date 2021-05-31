import SwiftUI
import UniformTypeIdentifiers


struct HomeCollectionView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @EnvironmentObject var model: HomeViewModel
    let offsetChanged: (CGPoint) -> Void
    
    @State private var dropData = DropData()
    
    var body: some View {
        OffsetAwareScrollView(offsetChanged: offsetChanged) {
            LazyVGrid(columns: columns) {
                ForEach(model.cellData) { data in
                    NavigationLink(
                        destination: model.coordinator.documentView(
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
                        delegate: HomeCollectionDropInsideDelegate(delegateData: data, cellData: $model.cellData, data: $dropData)
                    )
                }
            }
            .padding()
        }
        .animation(.spring())
        .ignoresSafeArea()
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView(offsetChanged: { _ in })
    }
}
