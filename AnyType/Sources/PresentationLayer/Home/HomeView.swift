import SwiftUI

struct HomeView: View {
    private let bottomSheetHeightRatio: CGFloat = 0.89
    @StateObject var model: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    @State private var showSettings = false
    
    var body: some View {
        contentView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(accountData)
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
            }
        }
        .edgesIgnoringSafeArea(.all)
        
        .toolbar {
            ToolbarItem {
                Button(action: {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.ripple) { showSettings.toggle() }
                }) {
                    Image.main.settings
                }
            }
        }
        .bottomFloater(isPresented: $showSettings) {
            model.coordinator.settingsView().padding(8)
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
