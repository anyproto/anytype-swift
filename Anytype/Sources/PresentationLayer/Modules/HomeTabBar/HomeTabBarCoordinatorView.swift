import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeTabBarCoordinatorView: View {

    @StateObject private var model: HomeTabBarCoordinatorViewModel
    
    
    init(spaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeTabBarCoordinatorViewModel(spaceInfo: spaceInfo))
    }
    
    var body: some View {
        ZStack {
            if FeatureFlags.homeSpaceLevelChat, let chatData = model.chatData {
                tabBarBody(chatData: chatData)
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
    
    private func tabBarBody(chatData: ChatCoordinatorData) -> some View {
        ZStack {
            HomeWallpaperView(spaceInfo: model.spaceInfo)
            
            HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
                .anytypeNavigationItemData(HomeTabState.widgets)
                .homeBottomPanelState($model.bottomPanelState)
                .opacity(model.tab == .widgets ? 1 : 0)
            
            ChatCoordinatorView(data: chatData)
                .anytypeNavigationItemData(HomeTabState.chat)
                .homeBottomPanelState($model.bottomPanelState)
                .opacity(model.tab == .chat ? 1 : 0)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTabBarView(icon: model.spaceIcon, state: $model.tab)
        }
        .homeBottomPanelHidden(bottomPanelHidden)
    }
    
    private var bottomPanelHidden: Bool {
        model.bottomPanelState.hidden(for: model.tab) ?? true
    }
}
