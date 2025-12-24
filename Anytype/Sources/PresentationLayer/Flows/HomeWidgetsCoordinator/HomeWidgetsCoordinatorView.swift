import SwiftUI
import AnytypeCore
import Services

enum WidgetNavigationButtonType: Hashable {
    case burger
    case arrowBack
}

struct HomeWidgetData: Hashable, Identifiable {
    let spaceId: String
    var navigationButtonType: WidgetNavigationButtonType = .burger

    var id: String { spaceId }
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData

    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) {
            HomeWidgetsCoordinatorInternalView(info: $0, navigationButtonType: data.navigationButtonType)
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {

    @State private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    let navigationButtonType: WidgetNavigationButtonType

    init(info: AccountInfo, navigationButtonType: WidgetNavigationButtonType) {
        self._model = State(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
        self.navigationButtonType = navigationButtonType
    }

    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, output: model, navigationButtonType: navigationButtonType)
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
