import SwiftUI
import Amplitude
import AnytypeCore

struct HomeView: View {
    @ObservedObject var model: HomeViewModel
    
    @StateObject private var settingsModel = SettingsViewModel(authService: ServiceLocator.shared.authService())
    
    @State var bottomSheetState = HomeBottomSheetViewState.closed
    @State private var showSettings = false
    @State private var showKeychainAlert = UserDefaultsConfig.showKeychainAlert
    @State private var isFirstLaunchAfterRegistration = ServiceLocator.shared.loginStateService().isFirstLaunchAfterRegistration

    var body: some View {
        navigationView
            .environment(\.font, .defaultAnytype)
            .environmentObject(model)
            .environmentObject(settingsModel)
            .onAppear {
                Amplitude.instance().logEvent(AmplitudeEventsName.homeShow)

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
                            Amplitude.instance().logEvent(AmplitudeEventsName.settingsShow)
                        }
                    }
                }) {
                    Image.main.settings
                }
            }
        }
        .bottomFloater(isPresented: $showSettings) {
            SettingsView()
                .readabilityPadding(8)
        }

        .bottomFloater(isPresented: $model.showDeletionAlert) {
            DashboardDeletionAlert()
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: model.showDeletionAlert)

        .bottomFloater(isPresented: $settingsModel.loggingOut) {
            DashboardLogoutAlert()
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.loggingOut)
        
        .bottomFloater(isPresented: $settingsModel.other) {
            OtherSettingsView()
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.other)
        
        .bottomFloater(isPresented: $settingsModel.clearCacheAlert) {
            DashboardClearCacheAlert()
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: settingsModel.clearCacheAlert)
        .onChange(of: settingsModel.clearCacheAlert) { showClearCacheAlert in
            if showClearCacheAlert {
                Amplitude.instance().logEvent(AmplitudeEventsName.clearFileCacheAlertShow)
            }
        }
        
        .bottomFloater(isPresented: $showKeychainAlert) {
            DashboardKeychainReminderAlert(shownInContext: isFirstLaunchAfterRegistration ? .signup : .settings)
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: showKeychainAlert)
        .onChange(of: showKeychainAlert) {
            UserDefaultsConfig.showKeychainAlert = $0

            if isFirstLaunchAfterRegistration {
                Amplitude.instance().logKeychainPhraseShow(.signup)
            }
        }
        
        .bottomFloater(isPresented: $model.loadingAlertData.showAlert) {
            DashboardLoadingAlert(text: model.loadingAlertData.text)
                .readabilityPadding(8)
        }
        .animation(.fastSpring, value: model.loadingAlertData.showAlert)
        
        .sheet(isPresented: $model.showSearch) {
            HomeSearchView()
                .environmentObject(model)
                .onChange(of: model.showSearch) { showSearch in
                    Amplitude.instance().logEvent(AmplitudeEventsName.searchShow)
                }
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
