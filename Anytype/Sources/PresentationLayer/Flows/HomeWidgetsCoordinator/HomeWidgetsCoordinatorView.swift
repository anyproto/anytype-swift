import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable {
    let info: AccountInfo
}

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: HomeWidgetData) {
        self._model = StateObject(wrappedValue: HomeWidgetsCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.showChangeSourceData) {
                WidgetChangeSourceSearchView(data: $0) {
                    model.onFinishChangeSource(screenData: $0)
                }
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showCreateWidgetData) {
                CreateWidgetCoordinatorView(data: $0) {
                    model.onFinishCreateSource(screenData: $0)
                }
            }
            .sheet(item: $model.showSpaceSettingsData) {
                if FeatureFlags.newSettings {
                    NewSpaceSettingsCoordinatorView(workspaceInfo: $0)
                } else {
                    SpaceSettingsCoordinatorView(workspaceInfo: $0)
                }
            }
    }
}
