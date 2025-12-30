import Foundation
import SwiftUI
import AnytypeCore

struct WidgetContainerView<Content: View>: View {

    @State private var model: WidgetContainerViewModel
    @Binding private var homeState: HomeWidgetsState
    
    let name: String
    let icon: Icon?
    let badgeModel: MessagePreviewModel?
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
        badgeModel: MessagePreviewModel? = nil,
        dragId: String?,
        menuItems: [WidgetMenuItem] = [.changeType, .remove, .removeSystemWidget],
        onCreateObjectTap: (() -> Void)?,
        onHeaderTap: @escaping () -> Void,
        output: (any CommonWidgetModuleOutput)?,
        @ViewBuilder content: () -> Content
    ) {
        self._homeState = homeState
        self.name = name
        self.icon = icon
        self.badgeModel = badgeModel
        self.dragId = dragId
        self.onCreateObjectTap = onCreateObjectTap
        self.onHeaderTap = onHeaderTap
        self.content = content()
        self._model = State(
            initialValue: WidgetContainerViewModel(
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
                allowContent: Content.self != EmptyView.self,
                createObjectAction: model.homeState.isReadWrite ? onCreateObjectTap : nil,
                header: {
                    LinkWidgetDefaultHeader(
                        title: name,
                        titleColor: badgeModel?.titleColor ?? .Text.primary,
                        icon: icon,
                        rightAccessory: {
                            if let badgeModel, badgeModel.hasCounters {
                                HStack(spacing: 4) {
                                    if badgeModel.mentionCounter > 0 {
                                        MentionBadge(style: badgeModel.mentionCounterStyle)
                                    }
                                    if badgeModel.unreadCounter > 0 {
                                        CounterView(
                                            count: badgeModel.unreadCounter,
                                            style: badgeModel.unreadCounterStyle
                                        )
                                    }
                                }
                            }
                        },
                        onTap: {
                            onHeaderTap()
                        }
                    )
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
        if let onCreateObjectTap {
            Button {
                onCreateObjectTap()
            } label: {
                Text(Loc.new)
                Image(systemName: "square.and.pencil")
            }
            Divider()
        }
    }
}
