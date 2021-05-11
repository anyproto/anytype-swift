import SwiftUI

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.9
    @StateObject var model: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    var body: some View {
        contentView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(accountData)
            .onAppear(perform: model.fetchDashboardData)
            .onAppear(perform: makeNavigationBarTransparent)
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Image.main.wallpaper
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width)
                textEditorNavigation
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
        .embedInNavigation()
    }
    
    // Workaround for custom navigation inside text editor
    private var textEditorNavigation: some View {
        NavigationLink(
            destination: model.coordinator.documentView(
                selectedDocumentId: model.selectedDocumentId,
                shouldShowDocument: $model.showingDocument
            ).navigationBarHidden(true).edgesIgnoringSafeArea(.all),
            isActive: $model.showingDocument,
            label: { EmptyView() }
        )
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
