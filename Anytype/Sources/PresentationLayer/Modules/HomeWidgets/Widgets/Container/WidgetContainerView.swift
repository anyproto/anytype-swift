import Foundation
import SwiftUI
import AnytypeCore

enum WidgetMenuItem: String {
    case addBelow
    case changeSource
    case changeType
    case remove
}

// TODO: Delete in after migration
struct WidgetContainerView<Content: View, ContentVM: WidgetContainerContentViewModelProtocol>: View {
    
    @StateObject private var model: WidgetContainerViewModel<ContentVM>
    @ObservedObject var contentModel: ContentVM
    @Binding private var homeState: HomeWidgetsState
    
    var content: Content
    let name: String
    let icon: ImageAsset?
    let dragId: String?
    let menuItems: [WidgetMenuItem]
    let onCreateObjectTap: (() -> Void)?
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        homeState: Binding<HomeWidgetsState>,
        name: String,
        icon: ImageAsset? = nil,
        dragId: String?,
        menuItems: [WidgetMenuItem] = [.addBelow, .changeSource, .changeType, .remove],
        onCreateObjectTap: (() -> Void)?,
        contentModel: ContentVM,
        output: CommonWidgetModuleOutput?,
        content: Content
    ) {
        self.contentModel = contentModel
        self.content = content
        self._homeState = homeState
        self.name = name
        self.icon = icon
        self.dragId = dragId
        self.menuItems = menuItems
        self.onCreateObjectTap = onCreateObjectTap
        self._model = StateObject(
            wrappedValue: WidgetContainerViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                contentModel: contentModel,
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
                homeState: model.homeState,
                allowMenuContent: menuItems.isNotEmpty,
                allowContent: Content.self != EmptyView.self,
                headerAction: {
                    contentModel.onHeaderTap()
                },
                removeAction: removeAction(),
                menu: {
                    menuItemsView
                },
                content: {
                    content
                }
            )
            .if(model.homeState.isReadWrite) {
                $0.contextMenu {
                    contextMenuItems
                }
            }
            .snackbar(toastBarData: $model.toastData)
        }
        .twoWayBinding(viewState: $homeState, modelState: $model.homeState)
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        if model.homeState.isReadWrite {
            ForEach(menuItems, id: \.self) {
                menuItemToView(item: $0)
            }
            Divider()
            Button(Loc.Widgets.Actions.editWidgets) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    model.onEditTap()
                }
            }
        }
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
        case .changeSource:
            Button(Loc.Widgets.Actions.changeSource) {
                model.onChangeSourceTap()
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
