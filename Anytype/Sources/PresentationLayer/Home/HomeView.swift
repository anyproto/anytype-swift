import SwiftUI
import Amplitude
import AnytypeCore

struct HomeView: View {
    @ObservedObject var model: HomeViewModel
    
    @StateObject private var settingsModel = SettingsViewModel(authService: ServiceLocator.shared.authService())
    @StateObject private var accountData = AccountInfoDataAccessor()
    
    @State var bottomSheetState = HomeBottomSheetViewState.closed
    @State private var showSettings = false
    @State private var showKeychainAlert = UserDefaultsConfig.showKeychainAlert

    var body: some View {
        navigationView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(settingsModel)
            .environmentObject(accountData)
            .onAppear {
                Amplitude.instance().logEvent(AmplitudeEventsName.dashboardPage)

                model.onAppear()
                
                UserDefaultsConfig.storeOpenedScreenData(nil)
            }
            .onDisappear {
                model.onDisappear()
            }
    }
    
    private var navigationView: some View {
        contentView
        .edgesIgnoringSafeArea(.all)
        .coordinateSpace(name: model.bottomSheetCoordinateSpaceName)

        .toolbar {
            ToolbarItem {
                Button(action: {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.fastSpring) {
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

        .bottomFloater(isPresented: $model.showDeletionAlert) {
            DashboardDeletionAlert().padding(8)
        }
        .animation(.fastSpring, value: model.showDeletionAlert)

        .bottomFloater(isPresented: $settingsModel.loggingOut) {
            DashboardLogoutAlert().padding(8)
        }
        .animation(.fastSpring, value: settingsModel.loggingOut)
        
        .bottomFloater(isPresented: $settingsModel.other) {
            OtherSettingsView()
        }
        .animation(.fastSpring, value: settingsModel.other)
        
        .bottomFloater(isPresented: $settingsModel.clearCacheAlert) {
            DashboardClearCacheAlert().padding(8)
        }
        .animation(.fastSpring, value: settingsModel.clearCacheAlert)
        
        .bottomFloater(isPresented: $showKeychainAlert) {
            DashboardKeychainReminderAlert().padding(8)
        }
        .animation(.fastSpring, value: showKeychainAlert)
        .onChange(of: showKeychainAlert) { UserDefaultsConfig.showKeychainAlert = $0 }
        
        .bottomFloater(isPresented: $model.loadingAlertData.showAlert) {
            DashboardLoadingAlert(text: model.loadingAlertData.text).padding(8)
        }
        .animation(.fastSpring, value: model.loadingAlertData.showAlert)
        
        .sheet(isPresented: $model.showSearch) {
            HomeSearchView()
                .environmentObject(model)
        }
        
        .snackbar(
            isShowing: $model.snackBarData.showSnackBar,
            text: AnytypeText(model.snackBarData.text, style: .uxCalloutRegular, color: .textPrimary)
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
        NavigationLink(
            destination: model.createBrowser(),
            isActive: $model.openedPageData.showing,
            label: { EmptyView() }
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel())
    }
}
