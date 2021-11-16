import SwiftUI
import Amplitude
import AnytypeCore

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @StateObject private var settingsModel = SettingsViewModel(authService: ServiceLocator.shared.authService())
    @StateObject private var accountData = AccountInfoDataAccessor()
    
    @State var bottomSheetState = HomeBottomSheetViewState.closed
    @State private var showSettings = false

    var body: some View {
        navigationView
            .environment(\.font, .defaultAnytype)
            .environmentObject(viewModel)
            .environmentObject(settingsModel)
            .environmentObject(accountData)
            .onAppear {
                Amplitude.instance().logEvent(AmplitudeEventsName.dashboardPage)

                viewModel.viewLoaded()
                
                UserDefaultsConfig.storeOpenedScreenData(nil)
            }
    }
    
    private var navigationView: some View {
        contentView
        .edgesIgnoringSafeArea(.all)
        .coordinateSpace(name: viewModel.bottomSheetCoordinateSpaceName)

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
            SettingsView().padding(8)
        }

        .bottomFloater(isPresented: $viewModel.showDeletionAlert) {
            DashboardDeletionAlert().padding(8)
        }
        .animation(.ripple, value: viewModel.showDeletionAlert)

        .bottomFloater(isPresented: $settingsModel.loggingOut) {
            DashboardLogoutAlert().padding(8)
        }
        .animation(.ripple, value: settingsModel.loggingOut)
        
        .bottomFloater(isPresented: $settingsModel.other) {
            OtherSettingsView()
        }
        .animation(.ripple, value: settingsModel.other)
        
        .bottomFloater(isPresented: $settingsModel.clearCacheAlert) {
            DashboardClearCacheAlert().padding(8)
        }
        .animation(.ripple, value: settingsModel.clearCacheAlert)
        
        .sheet(isPresented: $viewModel.showSearch) {
            HomeSearchView()
        }
        
        .snackbar(
            isShowing: $viewModel.snackBarData.showSnackBar,
            text: AnytypeText(viewModel.snackBarData.text, style: .uxCalloutRegular, color: .textPrimary)
        )
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    DashboardWallpaper()
                    newPageNavigation
                    HomeProfileView()
                    
                    HomeBottomSheetView(containerHeight: geometry.size.height, state: $bottomSheetState) {
                        HomeTabsView(offsetChanged: offsetChanged, onDrag: onDrag, onDragEnd: onDragEnd)
                    }
                    DashboardSelectionActionsView()
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    private var newPageNavigation: some View {
        Group {
            NavigationLink(
                destination: viewModel.createBrowser(),
                isActive: $viewModel.openedPageData.showing,
                label: { EmptyView() }
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
