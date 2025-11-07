import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable {
    let spaceId: String
    let route: HomeWidgetRoute?
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData

    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) {
            HomeWidgetsCoordinatorInternalView(info: $0, route: data.route)
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {

    @State private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    let route: HomeWidgetRoute?

    init(info: AccountInfo, route: HomeWidgetRoute?) {
        self._model = State(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
        self.route = route
    }
    
    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, output: model, route: route)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .anytypeSheet(item: $model.createTypeData) {
                CreateObjectTypeView(data: $0)
            }
            .anytypeSheet(item: $model.deleteSystemWidgetConfirmationData) {
                DeleteSystemWidgetConfirmation(data: $0)
            }
    }
}
