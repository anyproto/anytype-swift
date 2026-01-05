import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable, Identifiable {
    let spaceId: String
    
    var id: String { spaceId }
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData
    let navigationButtonType: PageNavigationButtonType

    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) {
            HomeWidgetsCoordinatorInternalView(info: $0, navigationButtonType: navigationButtonType)
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {

    @State private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation

    let navigationButtonType: PageNavigationButtonType

    init(info: AccountInfo, navigationButtonType: PageNavigationButtonType) {
        self._model = State(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
        self.navigationButtonType = navigationButtonType
    }

    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, navigationButtonType: navigationButtonType, output: model)
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
