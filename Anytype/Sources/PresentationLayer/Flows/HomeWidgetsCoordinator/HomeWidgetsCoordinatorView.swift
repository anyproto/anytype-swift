import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable {
    let spaceId: String
}

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: HomeWidgetData) {
        self._model = StateObject(wrappedValue: HomeWidgetsCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        if let spaceInfo = model.spaceInfo {
            content(info: spaceInfo)
        }
    }
    
    private func content(info: AccountInfo) -> some View {
        HomeWidgetsView(info: info, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
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
                SpaceSettingsCoordinatorView(workspaceInfo: $0)
            }
    }
}
