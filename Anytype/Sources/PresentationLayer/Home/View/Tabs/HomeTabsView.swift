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
            HomeCollectionView(cellData: model.favoritesCellData, coordinator: model.coordinator, cellDataManager: model, offsetChanged: offsetChanged).tag(1)
                .ignoresSafeArea()
            HomeCollectionView(cellData: model.archiveCellData, coordinator: model.coordinator, cellDataManager: model, offsetChanged: offsetChanged).tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    
    private var tabHeaders: some View {
        HStack(){
            Button(action: {
                withAnimation(.spring()) {
                    tabSelection = 1
                }
            }) {
                HomeTabsHeaderText(text: "Favorites", isSelected: tabSelection == 1)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    tabSelection = 4
                }
            }) {
                HomeTabsHeaderText(text: "Archive", isSelected: tabSelection == 4)
            }
        }
        .padding(.top)
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
