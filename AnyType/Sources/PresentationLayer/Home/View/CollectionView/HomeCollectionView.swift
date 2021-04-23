import SwiftUI

struct HomeCollectionView: View {
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns) {
                ForEach(0...99, id: \.self) { _ in
                    PageCell().cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color.orange)
        .ignoresSafeArea()
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView()
    }
}
