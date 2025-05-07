import Foundation
import SwiftUI
import AnytypeCore

struct WidgetContainerView<Content: View>: View {
    
    @StateObject private var model: WidgetContainerViewModel
    @Binding private var homeState: HomeWidgetsState
    
    let name: String
    let icon: ImageAsset?
    let dragId: String?
    let menuItems: [WidgetMenuItem]
    let onCreateObjectTap: (() -> Void)?
    let onHeaderTap: () -> Void
    let content: Content
    
    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        homeState: Binding<HomeWidgetsState>,
        name: String,
        icon: ImageAsset? = nil,
        dragId: String?,
        menuItems: [WidgetMenuItem] = [.addBelow, .changeType, .remove],
        onCreateObjectTap: (() -> Void)?,
        onHeaderTap: @escaping () -> Void,
        output: (any CommonWidgetModuleOutput)?,
        @ViewBuilder content: () -> Content
    ) {
        self._homeState = homeState
        self.name = name
        self.icon = icon
        self.dragId = dragId
        let numberOfWidgetLayouts = widgetObject.widgetInfo(blockId: widgetBlockId)?.source.availableWidgetLayout.count ?? 0
        self.menuItems = numberOfWidgetLayouts > 1 ? menuItems : menuItems.filter { $0 != .changeType }
        self.onCreateObjectTap = onCreateObjectTap
        self.onHeaderTap = onHeaderTap
        self.content = content()
        self._model = StateObject(
            wrappedValue: WidgetContainerViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                output: output
            )
        )
    }
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: onCreateObjectTap != nil && model.homeState.isReadWrite,
            showTitle: model.isExpanded,
            action: {
                if #available(iOS 17.0, *) {
                    WidgetSwipeTip().invalidate(reason: .actionPerformed)
                }
                onCreateObjectTap?()
            }
        ) {
            LinkWidgetViewContainer(
                isExpanded: $model.isExpanded,
                dragId: dragId,
                homeState: $model.homeState,
                allowMenuContent: menuItems.isNotEmpty,
                allowContent: Content.self != EmptyView.self,
                removeAction: removeAction(),
                createObjectAction: onCreateObjectTap,
                header: {
                    LinkWidgetDefaultHeader(title: name, icon: icon, onTap: {
                        onHeaderTap()
                    })
                },
                menu: {
                    menuItemsView
                },
                content: {
                    content
                }
            )
            .snackbar(toastBarData: $model.toastData)
        }
        .twoWayBinding(viewState: $homeState, modelState: $model.homeState)
    }
    
    @ViewBuilder
    private var menuItemsView: some View {
        WidgetCommonActionsMenuView(
            items: menuItems,
            widgetBlockId: model.widgetBlockId,
            widgetObject: model.widgetObject,
            homeState: model.homeState,
            output: model.output
        )
    }
            
    private func removeAction() -> (() -> Void)? {
        
        guard menuItems.contains(.remove) else { return nil }
        
        return {
            model.onDeleteWidgetTap()
        }
    }
}
