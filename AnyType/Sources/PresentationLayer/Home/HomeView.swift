import SwiftUI

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.9
    @ObservedObject var model: HomeViewModel
    
    
    var body: some View {
        GeometryReader { geometry in
            Color.blue
            HomeProfileView()
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            HomeBottomSheetView(maxHeight: geometry.size.height * bottomSheetHeightRatio) {
                HomeTabsView(cellData: $model.cellData)
            }
            
        }.edgesIgnoringSafeArea(.all)
        
        .environment(\.font, .defaultAnyType)
        .onAppear {
            model.fetchDashboardData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
