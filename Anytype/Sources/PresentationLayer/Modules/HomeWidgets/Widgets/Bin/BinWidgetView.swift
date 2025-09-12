import Foundation
import SwiftUI
import AnytypeCore

struct BinWidgetView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        BinWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct BinWidgetSubmoduleInternalView: View {
    
    @Binding private var homeState: HomeWidgetsState
    @StateObject private var model: BinWidgetViewModel
    
    init(data: WidgetSubmoduleData) {
        self._homeState = data.homeState
        self._model = StateObject(wrappedValue: BinWidgetViewModel(data: data))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: model.dragId,
            homeState: $homeState,
            allowMenuContent: true,
            allowContent: false,
            removeAction: {
                model.onDeleteWidgetTap()
            },
            header: {
                LinkWidgetDefaultHeader(title: Loc.bin, icon: .X24.bin, onTap: {
                    model.onHeaderTap()
                })
            },
            menu: {
                menu
            },
            content: { EmptyView() }
        )
        .anytypeSheet(item: $model.binAlertData) { data in
            BinConfirmationAlert(data: data)
        }
        .snackbar(toastBarData: $model.toastData)
    }
    
    @ViewBuilder
    private var menu: some View {
        if !FeatureFlags.homeObjectTypeWidgets {
            WidgetCommonActionsMenuView(
                items: [.addBelow, .remove],
                widgetBlockId: model.widgetBlockId,
                widgetObject: model.widgetObject,
                homeState: homeState,
                output: model.output
            )
            Divider()
        }
        AsyncButton(Loc.Widgets.Actions.emptyBin, role: .destructive) {
            try await model.onEmptyBinTap()
        }
    }
}
