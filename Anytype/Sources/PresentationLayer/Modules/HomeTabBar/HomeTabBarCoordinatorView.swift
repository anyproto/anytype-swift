import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeTabBarCoordinatorView: View {

    @StateObject private var model: HomeTabBarCoordinatorViewModel
    
    @State private var widgetsBottomPanelHidden = false
    @State private var chatBottomPanelHidden = false
    
    init(spaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeTabBarCoordinatorViewModel(spaceInfo: spaceInfo))
    }
    
    var body: some View {
        ZStack {
            if FeatureFlags.homeSpaceLevelChat {
                tabBarBody
            } else {
                widgetsOnlyBody
            }
        }
        .task {
            await model.startSubscription()
        }
    }
    
    private var widgetsOnlyBody: some View {
        ZStack {
            HomeWallpaperView(spaceInfo: model.spaceInfo)
            HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
        }
    }
    
    private var tabBarBody: some View {
        ZStack {
            HomeWallpaperView(spaceInfo: model.spaceInfo)
            
            HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
                .setHomeBottomPanelHiddenHandler($widgetsBottomPanelHidden)
                .opacity(model.tab == .widgets ? 1 : 0)
            
            HomeChatCoordinatorView(spaceInfo: model.spaceInfo)
                .setHomeBottomPanelHiddenHandler($chatBottomPanelHidden)
                .opacity(model.tab == .chat ? 1 : 0)
        }
        .safeAreaInset(edge: .top) {
            HomeTabBarView(name: model.spaceName, icon: model.spaceIcon, state: $model.tab)
        }
        .homeBottomPanelHidden(bottomPanelHidden)
    }
    
    private var bottomPanelHidden: Bool {
        switch model.tab {
        case .widgets:
            return widgetsBottomPanelHidden
        case .chat:
            return chatBottomPanelHidden
        }
    }
}
