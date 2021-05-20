import SwiftUI
import PopupView

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.9
    @StateObject var model: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    @State private var showSettings = false
    
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
                Group {
                    Image.main.wallpaper.resizable().aspectRatio(contentMode: .fill)
                    newPageNavigation
                    HomeProfileView()
                    
                    HomeBottomSheetView(maxHeight: geometry.size.height * bottomSheetHeightRatio) {
                        HomeTabsView()
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height)
                
                if showSettings { // Black background overlay
                    Color.black.opacity(0.25).ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(1) // https://stackoverflow.com/a/58512696/6252099
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        
        .toolbar {
            ToolbarItem {
                Button(action: { withAnimation { showSettings = true } }) {
                    Image.main.settings
                }
            }
        }
        
        .popup(isPresented: $showSettings.animation(), type: .floater(verticalPadding: 42),
               closeOnTap: false, closeOnTapOutside: true
        ) {
            model.coordinator.profileView()
                .padding(8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var newPageNavigation: some View {
        NavigationLink(
            destination: model.coordinator.documentView(
                selectedDocumentId: model.newPageData.pageId
            ).edgesIgnoringSafeArea(.all),
            isActive: $model.newPageData.showingNewPage,
            label: { EmptyView() }
        )
    }
    
    private func makeNavigationBarTransparent() {
        windowHolder?.changeNavigationBarCollor(color: .clear)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
