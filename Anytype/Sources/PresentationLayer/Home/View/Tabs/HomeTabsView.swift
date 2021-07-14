import SwiftUI

struct HomeTabsView: View {
    @EnvironmentObject var model: HomeViewModel
    @State private var tabSelection = 1    
    
    let offsetChanged: (CGPoint) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            tabHeaders
            tabs
        }
    }
    
    private var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView(cellData: model.nonArchivedFavoritesCellData, coordinator: model.coordinator, dragAndDropDelegate: model, offsetChanged: offsetChanged).tag(1)
            HomeCollectionView(cellData: model.recentCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged).tag(2)
            HomeCollectionView(cellData: model.inboxCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged).tag(3)
            HomeCollectionView(cellData: model.archiveCellData, coordinator: model.coordinator, dragAndDropDelegate: nil, offsetChanged: offsetChanged).tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    
    private var tabHeaders: some View {
        HStack(){
            tabButton(text: "Favorites", tag: 1)
            tabButton(text: "Recent", tag: 2)
            tabButton(text: "Inbox", tag: 3)
            tabButton(text: "Archive", tag: 4)
        }
        .padding([.leading, .top, .trailing])
    }
    
    private func tabButton(text: String, tag: Int) -> some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    tabSelection = tag
                }
            }
        ) {
            HomeTabsHeaderText(text: text, isSelected: tabSelection == tag)
        }
    }
}

struct HomeTabsView_Previews: PreviewProvider {
    static var model: HomeViewModel {
        let model = HomeViewModel()
        return model
    }
    
    static var previews: some View {
        ZStack {
            Color.blue
            HomeTabsView(offsetChanged: { _ in })
                .environmentObject(model)
        }
    }
}
