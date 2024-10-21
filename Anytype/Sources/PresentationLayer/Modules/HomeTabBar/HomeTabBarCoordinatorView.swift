import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeTabBarCoordinatorView: View {

    private enum TabState {
        case home
        case chat
    }
    
    let spaceInfo: AccountInfo
    
    @State private var tab: TabState = .chat
    
    var body: some View {
        if FeatureFlags.homeSpaceLevelChat {
            tabBarBody
        } else {
            widgetsOnlyBody
        }
    }
    
    var widgetsOnlyBody: some View {
        HomeWidgetsCoordinatorView(spaceInfo: spaceInfo)
    }
    
    var tabBarBody: some View {
        ZStack {
            HomeWidgetsCoordinatorView(spaceInfo: spaceInfo)
                .opacity(tab == .home ? 1 : 0)
            
            HomeChatCoordinatorView(spaceInfo: spaceInfo)
                .opacity(tab == .chat ? 1 : 0)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button("Home") {
                    tab = .home
                }
                Button("Chat") {
                    tab = .chat
                }
            }
        }
    }
}
