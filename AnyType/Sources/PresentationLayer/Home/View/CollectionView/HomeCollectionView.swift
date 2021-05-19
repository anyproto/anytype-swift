import SwiftUI

struct HomeCollectionView: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @EnvironmentObject var model: HomeViewModel
    
    var body: some View {
        ScrollView() {
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
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .animation(.interactiveSpring())
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView()
    }
}
