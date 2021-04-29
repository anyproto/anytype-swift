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
                ForEach(model.cellData.indexed(), id: \.1.id) { index, _ in
                    NavigationLink(destination: model.coordinator.profileView()) {
                        PageCellWrapper(cellData: $model.cellData, index: index)
                    }
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .animation(.interactiveSpring())
    }
}

// https://blog.apptekstudios.com/2020/05/quick-tip-avoid-crash-when-using-foreach-bindings-in-swiftui/
// fixes crash in ForEach indexes race condition upon cell data delition
fileprivate struct PageCellWrapper: View {
    @Binding var cellData: [PageCellData]
    let index: Int
    
    var body: some View {
        if index >= cellData.count {
            EmptyView()
        } else {
            PageCell(cellData: $cellData[index])
                .cornerRadius(16)
                .frame(idealHeight: 124)
        }
    }
}

struct HomeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCollectionView()
    }
}

