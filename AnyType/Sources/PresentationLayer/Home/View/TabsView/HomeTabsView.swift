import SwiftUI

struct HomeTabsView: View {
    @State private var tabSelection = 1    
        
    var body: some View {
        GeometryReader() { fullView in
            VStack {
                tabHeaders
                tabs
            }
        }
        .animation(.interactiveSpring(), value: tabSelection)
    }
    
    var tabs: some View {
        TabView(selection: $tabSelection) {
            HomeCollectionView().tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    
    var tabHeaders: some View {
        HStack(){
            Button(action: {
                tabSelection = 1
            }) {
                HomeTabsHeaderText(text: "Favorites", isSelected: tabSelection == 1)
            }

            Button(action: {
                tabSelection = 2
            }) {
                HomeTabsHeaderText(text: "Recent", isSelected: tabSelection == 2)
            }.disabled(true)
            
            Button(action: {
                tabSelection = 3
            }) {
                HomeTabsHeaderText(text: "Drafts", isSelected: tabSelection == 3)
            }.disabled(true)
            
            Button(action: {
                tabSelection = 4
            }) {
                HomeTabsHeaderText(text: "Bin", isSelected: tabSelection == 4)
            }.disabled(true)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
    }
}

struct HomeTabsView_Previews: PreviewProvider {
    static var model: HomeViewModel {
        let model = HomeViewModel()
        model.cellData = PageCellDataMock.data
        return model
    }
    
    static var previews: some View {
        ZStack {
            Color.blue
            HomeTabsView()
                .environmentObject(model)
        }
    }
}
