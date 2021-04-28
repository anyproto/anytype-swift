import SwiftUI

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.9
    @StateObject var model: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    var body: some View {
        contentView
            .environment(\.font, .defaultAnyType)
            .environmentObject(model)
            .environmentObject(accountData)
            .onAppear(perform: model.fetchDashboardData)
            .onAppear(perform: makeNavigationBarTransparent)
    }
    
    private var contentView: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0, green: 102.0/255.0, blue: 195.0/255.0)
                    HomeProfileView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    HomeBottomSheetView(maxHeight: geometry.size.height * bottomSheetHeightRatio) {
                        HomeTabsView()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: model.coordinator.profileView()) {
                        Image.main.settings
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func makeNavigationBarTransparent() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
