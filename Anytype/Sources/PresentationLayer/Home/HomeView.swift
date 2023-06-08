import SwiftUI
import AnytypeCore

struct HomeView: View {
    @ObservedObject var model: HomeViewModel
    
    @State var bottomSheetState = HomeBottomSheetViewState.closed
    @State private var showKeychainAlert = UserDefaultsConfig.showKeychainAlert

    init(model: HomeViewModel) {
        self.model = model
    }
    
    var body: some View {
        navigationView
            .environment(\.font, .defaultAnytype)
            .onAppear {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.homeShow)

                model.onAppear()
                
                UserDefaultsConfig.storeOpenedScreenData(nil)
            }
            .onDisappear {
                model.onDisappear()
            }
            .redacted(reason: model.loadingDocument ? .placeholder : [])
            .allowsHitTesting(!model.loadingDocument)
    }
    
    private var navigationView: some View {
        contentView
        .edgesIgnoringSafeArea(.all)
        .coordinateSpace(name: model.bottomSheetCoordinateSpaceName)

        .toolbar {
            ToolbarItem {
                Button(action: {
                    UISelectionFeedbackGenerator().selectionChanged()
                    model.showSettings()
                }) {
                    model.loadingDocument ? nil : Image(asset: .mainSettings)
                }
                .allowsHitTesting(!model.loadingDocument)
            }
        }

        .bottomFloater(isPresented: $model.showPagesDeletionAlert) {
            DashboardDeletionAlert(model: model)
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: model.showPagesDeletionAlert)
        
        .bottomFloater(isPresented: $showKeychainAlert) {
            model.makeKeychainAlert()
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: showKeychainAlert)
        .onChange(of: showKeychainAlert) {
            UserDefaultsConfig.showKeychainAlert = $0

            if model.isFirstLaunchAfterRegistration {
                AnytypeAnalytics.instance().logKeychainPhraseShow(.signup)
            }
        }
        
        .bottomFloater(isPresented: $model.loadingAlertData.showAlert) {
            DashboardLoadingAlert(text: model.loadingAlertData.text)
                .horizontalReadabilityPadding(8)
        }
        .animation(.fastSpring, value: model.loadingAlertData.showAlert)
        
        .sheet(isPresented: $model.showSearch) {
            HomeSearchView(viewModel: model)
                .onChange(of: model.showSearch) { showSearch in
                    AnytypeAnalytics.instance().logScreenSearch()
                }
        }   
        
        .snackbar(toastBarData: $model.snackBarData)
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    DashboardWallpaper()
                    if let data = model.openedEditorScreenData {
                        newPageNavigation(data: data)
                    }
                    HomeProfileView(model: model)
                    
                    HomeBottomSheetView(containerHeight: geometry.size.height, state: $bottomSheetState) {
                        HomeTabsView(model: model, showSpaceTab: model.enableSpace, offsetChanged: offsetChanged, onDrag: onDrag, onDragEnd: onDragEnd)
                    }
                    DashboardSelectionActionsView(model: model)
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    private func newPageNavigation(data: EditorScreenData) -> some View {
        NavigationLink(isActive: $model.showingEditorScreenData) {
            model.createBrowser(data: data)
        } label: {
            EmptyView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: HomeViewModel.makeForPreview())
    }
}
