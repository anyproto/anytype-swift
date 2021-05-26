import SwiftUI

struct HomeCollectionView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @EnvironmentObject var model: HomeViewModel
    let offsetChanged: (CGPoint) -> Void
    
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
