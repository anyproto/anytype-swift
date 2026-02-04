import SwiftUI
import AnytypeCore
import Services

struct HomeWidgetData: Hashable, Identifiable {
    let spaceId: String

    var id: String { spaceId }
}

enum WidgetScreenContext {
    case navigation
    case overlay

    var navigationButtonType: NavigationHeaderButtonType {
        switch self {
        case .navigation: return .back
        case .overlay: return .dismiss
        }
    }

    var showEmbeddedBottomPanel: Bool {
        switch self {
        case .navigation: return false
        case .overlay: return true
        }
    }
}

struct HomeWidgetsCoordinatorView: View {
    let data: HomeWidgetData
    let context: WidgetScreenContext

    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) {
            HomeWidgetsCoordinatorInternalView(info: $0, context: context)
        }
    }
}

private struct HomeWidgetsCoordinatorInternalView: View {

    @State private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation

    let context: WidgetScreenContext

    init(info: AccountInfo, context: WidgetScreenContext) {
        self._model = State(wrappedValue: HomeWidgetsCoordinatorViewModel(info: info))
        self.context = context
    }

    var body: some View {
        HomeWidgetsView(info: model.spaceInfo, context: context, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .sheet(item: $model.spaceShareData) {
                SpaceShareCoordinatorView(data: $0)
            }
            .anytypeSheet(item: $model.createTypeData) {
                CreateObjectTypeView(data: $0)
            }
            .anytypeSheet(item: $model.deleteSystemWidgetConfirmationData) {
                DeleteSystemWidgetConfirmation(data: $0)
            }
            .anytypeSheet(item: $model.qrCodeInviteData) {
                QrCodeView(title: Loc.joinSpace, data: $0.value.absoluteString, analyticsType: .inviteSpace, route: .inviteLink)
            }
    }
}
