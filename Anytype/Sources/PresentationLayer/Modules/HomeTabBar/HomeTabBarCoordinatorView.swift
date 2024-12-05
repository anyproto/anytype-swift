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
            if FeatureFlags.showHomeSpaceLevelChat(spaceId: model.spaceInfo.accountSpaceId), let chatData = model.chatData {
                tabBarBody(chatData: chatData)
            } else {
                widgetsOnlyBody
            }
        }
        .task {
            await model.startSubscription()
        }
        .sheet(item: $model.showSpaceSettingsData) {
            SpaceSettingsCoordinatorView(workspaceInfo: $0)
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
            
            HomeTabBarSwipeContainer(tab: $model.tab) {
                HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
                    .anytypeNavigationItemData(HomeTabState.widgets)
                    .homeBottomPanelState($model.bottomPanelState)
            } chatView: {
                ChatCoordinatorView(data: chatData)
                    .anytypeNavigationItemData(HomeTabState.chat)
                    .homeBottomPanelState($model.bottomPanelState)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTabBarView(icon: model.spaceIcon, state: $model.tab) {
                model.onSpaceSelected()
            }
        }
        .homeBottomPanelHidden(bottomPanelHidden)
    }
    
    private var bottomPanelHidden: Bool {
        model.bottomPanelState.hidden(for: model.tab) ?? true
    }
}
