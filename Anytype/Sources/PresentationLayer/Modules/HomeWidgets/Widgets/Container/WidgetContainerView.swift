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
    var content: Content
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        contentModel: ContentVM,
        output: CommonWidgetModuleOutput?,
        content: Content
    ) {
        self.contentModel = contentModel
        self.content = content
        self._model = StateObject(
            wrappedValue: WidgetContainerViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                stateManager: stateManager,
                contentModel: contentModel,
                output: output
            )
        )
    }
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: contentModel.allowCreateObject && model.homeState.isReadWrite,
            showTitle: model.isExpanded,
            action: {
                if #available(iOS 17.0, *) {
                    WidgetSwipeTip().invalidate(reason: .actionPerformed)
                }
                contentModel.onCreateObjectTap()
            }
        ) {
            LinkWidgetViewContainer(
                title: contentModel.name,
                icon: contentModel.icon,
                isExpanded: $model.isExpanded,
                dragId: contentModel.dragId,
                homeState: model.homeState,
                allowMenuContent: contentModel.menuItems.isNotEmpty,
                allowContent: contentModel.allowContent,
                headerAction: {
                    contentModel.onHeaderTap()
                },
                removeAction: removeAction(),
                menu: {
                    menuItems
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
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        if model.homeState.isReadWrite {
            ForEach(contentModel.menuItems, id: \.self) {
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
    private var menuItems: some View {
        ForEach(contentModel.menuItems, id: \.self) {
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
        
        guard contentModel.menuItems.contains(.remove) else { return nil }
        
        return {
            model.onDeleteWidgetTap()
        }
    }
}
