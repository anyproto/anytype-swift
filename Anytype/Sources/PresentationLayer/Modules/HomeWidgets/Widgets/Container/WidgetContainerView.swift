import Foundation
import SwiftUI
import AnytypeCore

struct WidgetContainerView<Content: View>: View {
    
    @StateObject private var model: WidgetContainerViewModel
    @Binding private var homeState: HomeWidgetsState
    
    let name: String
    let icon: Icon?
    let dragId: String?
    let onCreateObjectTap: (() -> Void)?
    let onHeaderTap: () -> Void
    let content: Content
    
    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        homeState: Binding<HomeWidgetsState>,
        name: String,
        icon: Icon? = nil,
        dragId: String?,
        menuItems: [WidgetMenuItem] = [.addBelow, .changeType, .remove, .removeSystemWidget],
        onCreateObjectTap: (() -> Void)?,
        onHeaderTap: @escaping () -> Void,
        output: (any CommonWidgetModuleOutput)?,
        @ViewBuilder content: () -> Content
    ) {
        self._homeState = homeState
        self.name = name
        self.icon = icon
        self.dragId = dragId
        self.onCreateObjectTap = onCreateObjectTap
        self.onHeaderTap = onHeaderTap
        self.content = content()
        self._model = StateObject(
            wrappedValue: WidgetContainerViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                expectedMenuItems: menuItems,
                output: output
            )
        )
    }
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: onCreateObjectTap != nil && model.homeState.isReadWrite,
            showTitle: model.isExpanded,
            action: {
                WidgetSwipeTip().invalidate(reason: .actionPerformed)
                onCreateObjectTap?()
            }
        ) {
            LinkWidgetViewContainer(
                isExpanded: $model.isExpanded,
                dragId: dragId,
                homeState: $model.homeState,
                allowMenuContent: model.menuItems.isNotEmpty,
                allowContent: Content.self != EmptyView.self,
                removeAction: removeAction(),
                createObjectAction: model.homeState.isReadWrite ? onCreateObjectTap : nil,
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
        createObjectMenuButton
        WidgetCommonActionsMenuView(
            items: model.menuItems,
            widgetBlockId: model.widgetBlockId,
            widgetObject: model.widgetObject,
            homeState: model.homeState,
            output: model.output
        )
    }
    
    @ViewBuilder
    private var createObjectMenuButton: some View {
        if FeatureFlags.homeObjectTypeWidgets, let onCreateObjectTap {
            Button {
                onCreateObjectTap()
            } label: {
                Text(Loc.new)
                Image(systemName: "square.and.pencil")
            }
            Divider()
        }
    }
            
    private func removeAction() -> (() -> Void)? {
        
        guard model.menuItems.contains(.remove) else { return nil }
        
        return {
            model.onDeleteWidgetTap()
        }
    }
}
