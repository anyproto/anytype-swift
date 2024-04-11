import Foundation
import SwiftUI

struct BinLinkWidgetView: View {
    
    let spaceId: String
    @Binding var homeState: HomeWidgetsState
    weak var output: CommonWidgetModuleOutput?

    var body: some View {
        BinLinkWidgetViewInternal(spaceId: spaceId, homeState: $homeState, output: output)
            .id(spaceId)
    }
}

private struct BinLinkWidgetViewInternal: View {
    
    @StateObject private var model: BinLinkWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(
        spaceId: String,
        homeState: Binding<HomeWidgetsState>,
        output: CommonWidgetModuleOutput?
    ) {
        self._homeState = homeState
        self._model = StateObject(wrappedValue: BinLinkWidgetViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        WidgetContainerViewNew(
            title: Loc.bin,
            icon: .Widget.bin,
            isExpanded: .constant(false),
            homeState: $homeState,
            dragId: nil,
            showSwipeActionTitle: false,
            onHeaderTap: {
                model.onHeaderTap()
            },
            onCreateObjectTap: nil,
            removeTap: nil,
            content: EmptyView(),
            menuItems: menuItems
        )
        .anytypeSheet(item: $model.binAlertData) { data in
            BinConfirmationAlert(data: data)
        }
        .snackbar(toastBarData: $model.toastData)
    }
    
    private var menuItems: some View {
        AsyncButton(Loc.Widgets.Actions.emptyBin, role: .destructive) {
            try await model.onEmptyBinTap()
        }
    }
}
