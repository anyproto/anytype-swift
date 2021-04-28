import SwiftUI

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.9
    @StateObject var model: HomeViewModel
    
    var body: some View {
        contentView
            .environment(\.font, .defaultAnyType)
            .environmentObject(model)
            .onAppear(perform: model.fetchDashboardData)
    }
    
    var contentView: some View {
        NavigationView {
            GeometryReader { geometry in
                Color.blue
                HomeProfileView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                HomeBottomSheetView(maxHeight: geometry.size.height * bottomSheetHeightRatio) {
                    HomeTabsView()
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
