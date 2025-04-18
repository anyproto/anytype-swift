import Foundation
import SwiftUI

struct AllObjectsWidgetView: View {
    
    @StateObject private var model: AllObjectsWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(data: WidgetSubmoduleData) {
        _homeState = data.homeState
        _model = StateObject(wrappedValue: AllObjectsWidgetViewModel(data: data))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            title: Loc.allObjects,
            icon: .Widget.allObjects,
            isExpanded: .constant(false),
            dragId: model.dragId,
            homeState: $homeState,
            allowMenuContent: true,
            allowContent: false,
            headerAction: {
                model.onHeaderTap()
            },
            removeAction: {
                model.onDeleteWidgetTap()
            },
            menu: {
                menu
            },
            content: { EmptyView() }
        )
        .id(model.data.widgetBlockId)
    }
    
    private var menu: some View {
        WidgetCommonActionsMenuView(
            items: [.addBelow, .remove],
            widgetBlockId: model.data.widgetBlockId,
            widgetObject: model.data.widgetObject,
            homeState: homeState,
            output: model.data.output
        )
    }
}
