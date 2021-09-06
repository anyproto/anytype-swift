import SwiftUI
import Amplitude


struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @StateObject private var accountData = AccountInfoDataAccessor()

    @State private var showSettings = false
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isSheetOpen = false
    
    private let bottomSheetHeightRatio: CGFloat = 0.89

    var body: some View {
        contentView
            .environment(\.font, .defaultAnytype)
            .environmentObject(viewModel)
            .environmentObject(accountData)
            .onAppear {
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.dashboardPage)

                viewModel.viewLoaded()
            }
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    Gradients.mainBackground()
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
                    withAnimation(.ripple) {
                        showSettings.toggle()
                        if showSettings {
                            // Analytics
                            Amplitude.instance().logEvent(AmplitudeEventsName.popupSettings)
                        }
                    }
                }) {
                    Image.main.settings
                }
            }
        }
        .bottomFloater(isPresented: $showSettings) {
            viewModel.coordinator.settingsView().padding(8)
        }
        .sheet(isPresented: $viewModel.showSearch) {
            HomeSearchView()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var newPageNavigation: some View {
        Group {
            NavigationLink(
                destination: viewModel.coordinator.documentView(
                    selectedDocumentId: viewModel.newPageData.pageId
                ),
                isActive: $viewModel.newPageData.showingNewPage,
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
        HomeView(viewModel: HomeViewModel())
    }
}
