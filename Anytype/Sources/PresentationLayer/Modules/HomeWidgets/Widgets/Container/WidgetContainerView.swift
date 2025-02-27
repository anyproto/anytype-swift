import Foundation
import SwiftUI
import AnytypeCore

enum WidgetMenuItem: String {
    case addBelow
    case changeType
    case remove
}

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
                title: name,
                icon: icon,
                isExpanded: $model.isExpanded,
                dragId: dragId,
                homeState: $model.homeState,
                allowMenuContent: menuItems.isNotEmpty,
                allowContent: Content.self != EmptyView.self,
                headerAction: {
                    onHeaderTap()
                },
                removeAction: removeAction(),
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
        ForEach(menuItems, id: \.self) {
            menuItemToView(item: $0)
        }
    }
    
    @ViewBuilder
    private func menuItemToView(item: WidgetMenuItem) -> some View {
        switch item {
        case .addBelow:
            Button(Loc.Widgets.Actions.addBelow) {
                model.onAddBelowTap()
            }
        case .changeType:
            Button(Loc.Widgets.Actions.changeWidgetType) {
                model.onChangeTypeTap()
            }
        case .remove:
            Button(Loc.Widgets.Actions.removeWidget, role: .destructive) {
                // Fix animation glitch.
                // We should to finalize context menu transition to list and then delete object
                // If we find how customize context menu transition, this 🩼 can be deleted
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    model.onDeleteWidgetTap()
                }
            }
        }
    }
            
    private func removeAction() -> (() -> Void)? {
        
        guard menuItems.contains(.remove) else { return nil }
        
        return {
            model.onDeleteWidgetTap()
        }
    }
}
