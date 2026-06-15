import Foundation
import SwiftUI

struct BinLinkWidgetView: View {

    let spaceId: String
    weak var output: (any CommonWidgetModuleOutput)?

    var body: some View {
        BinLinkWidgetViewInternal(spaceId: spaceId, output: output)
            .id(spaceId)
    }
}

private struct BinLinkWidgetViewInternal: View {

    @State private var model: BinLinkWidgetViewModel

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self._model = State(initialValue: BinLinkWidgetViewModel(spaceId: spaceId, output: output))
    }

    var body: some View {
        // Bin is only ever rendered when the user is readwrite — readonly is filtered out
        // upstream by HomeWidgetsViewModel.visibleSections — so the homeState binding
        // passed into LinkWidgetViewContainer is a constant.
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: .constant(.readwrite),
            allowContent: false,
            header: {
                LinkWidgetDefaultHeader(title: Loc.bin, icon: .asset(.X24.bin), onTap: {
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
