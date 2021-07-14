import SwiftUI

struct HomeView: View {
    @StateObject var model: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    @State private var showSettings = false
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isSheetOpen = false
    
    private let bottomSheetHeightRatio: CGFloat = 0.89

    var body: some View {
        contentView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(accountData)
            .onAppear {
                windowHolder?.configureNavigationBarWithTransparentBackground()
                model.updateSearchTabs()
            }
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    Image.main.wallpaper.resizable().aspectRatio(contentMode: .fill)
                    newPageNavigation
                    HomeProfileView()
                    
                    HomeBottomSheetView(maxHeight: geometry.size.height * bottomSheetHeightRatio, scrollOffset: $scrollOffset, isOpen: $isSheetOpen) {
                        HomeTabsView(offsetChanged: offsetChanged)
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
        Group {
            NavigationLink(
                destination: model.coordinator.documentView(
                    selectedDocumentId: model.newPageData.pageId
                ),
                isActive: $model.newPageData.showingNewPage,
                label: { EmptyView() }
            )
            NavigationLink(destination: EmptyView(), label: {}) // https://stackoverflow.com/a/67104650/6252099
        }
    }

    private let sheetOpenOffset: CGFloat = -5
    private let sheetCloseOffset: CGFloat = 40
    
    private func offsetChanged(_ offset: CGPoint) {
        if offset.y < sheetOpenOffset {
            withAnimation(.spring()) {
                if isSheetOpen == false {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                isSheetOpen = true
            }
        }
        if offset.y > sheetCloseOffset {
            withAnimation(.spring()) {
                if isSheetOpen == true {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                isSheetOpen = false
            }
        }

        scrollOffset = offset.y
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
