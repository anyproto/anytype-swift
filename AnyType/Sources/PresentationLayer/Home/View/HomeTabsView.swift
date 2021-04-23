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
            HomeCollectionView().tag(2)
            HomeCollectionView().tag(3)
            HomeCollectionView().tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
    
    
    var tabHeaders: some View {
        HStack {
            Button(action: {
                tabSelection = 1
            }) {
                Text("Favorites")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(tabSelection == 1 ? .black : .gray)
            }

            Button(action: {
                tabSelection = 2
            }) {
                Text("Recent")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(tabSelection == 2 ? .black : .gray)
            }
            
            Button(action: {
                tabSelection = 3
            }) {
                Text("Drafts")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(tabSelection == 3 ? .black : .gray)
            }
            
            Button(action: {
                tabSelection = 4
            }) {
                Text("Bin")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(tabSelection == 4 ? .black : .gray)
            }
        }
        .padding(.bottom, 20)
    }
}

struct HomeTabsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabsView()
    }
}
