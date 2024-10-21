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
    
    var widgetsOnlyBody: some View {
        HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
    }
    
    var tabBarBody: some View {
        ZStack {
            HomeWidgetsCoordinatorView(spaceInfo: model.spaceInfo)
                .opacity(model.tab == .widgets ? 1 : 0)
            
            HomeChatCoordinatorView(spaceInfo: model.spaceInfo)
                .opacity(model.tab == .chat ? 1 : 0)
        }
        .safeAreaInset(edge: .top) {
            HomeTabBarView(name: model.spaceName, icon: model.spaceIcon, state: $model.tab)
        }
    }
}
