import Foundation
import SwiftUI

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
            title: Loc.bin,
            icon: .Widget.bin,
            isExpanded: .constant(false),
            dragId: model.dragId,
            homeState: $homeState,
            allowMenuContent: true,
            allowContent: false,
            headerAction: {
                model.onHeaderTap()
            },
            removeAction: nil,
            menu: {
                EmptyView()
            },
            content: { EmptyView() }
        )
    }
}
