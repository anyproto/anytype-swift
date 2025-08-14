import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable {
    let spaceId: String
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData
    
    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) {
            HomeWidgetsCoordinatorInternalView(info: $0)
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {
    
    @StateObject private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(info: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
    }
    
    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, output: model)
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
    }
}
