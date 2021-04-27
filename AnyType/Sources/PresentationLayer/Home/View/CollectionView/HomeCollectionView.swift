import SwiftUI

struct HomeCollectionView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @Binding var cellData: [PageCellData]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(cellData) { data in
                    PageCell(cellData: data).cornerRadius(16)
                        .frame(idealHeight: 124)
                }
            }
            .padding()
        }
        .background(Color.orange)
        .ignoresSafeArea()
        .animation(.interactiveSpring())
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView(cellData: .constant(PageCellDataMock.data))
    }
}
