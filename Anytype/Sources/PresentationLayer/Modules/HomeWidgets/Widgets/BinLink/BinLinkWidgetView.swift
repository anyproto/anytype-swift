import Foundation
import SwiftUI

struct BinLinkWidgetView: View {
    
    let spaceId: String
    @Binding var homeState: HomeWidgetsState
    weak var output: (any CommonWidgetModuleOutput)?

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
        output: (any CommonWidgetModuleOutput)?
    ) {
        self._homeState = homeState
        self._model = StateObject(wrappedValue: BinLinkWidgetViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        if homeState.isReadWrite || homeState.isEditWidgets {
            content
        }
    }
    
    var content: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: $homeState,
            allowMenuContent: true,
            allowContent: false,
            removeAction: nil,
            header: {
                LinkWidgetDefaultHeader(title: Loc.bin, icon: .X24.bin, onTap: {
                    model.onHeaderTap()
                })
            },
            menu: {
                menuItems
            },
            content: { EmptyView() }
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
