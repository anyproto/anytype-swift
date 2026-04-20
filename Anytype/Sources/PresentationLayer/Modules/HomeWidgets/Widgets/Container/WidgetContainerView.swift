import Foundation
import SwiftUI
import AnytypeCore
import Services

struct WidgetContainerView<Content: View>: View {

    @State private var model: WidgetContainerViewModel
    @Binding private var homeState: HomeWidgetsState
    @Environment(\.shouldHideChatBadges) private var shouldHideChatBadges

    let name: String
    let icon: Icon?
    let badgeModel: MessagePreviewModel?
    let dragId: String?
    let contentState: WidgetContentState
    let onCreateObjectTap: (() -> Void)?
    let onHeaderTap: () -> Void
    let content: Content

    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        spaceInfo: AccountInfo,
        homeState: Binding<HomeWidgetsState>,
        name: String,
        icon: Icon? = nil,
        badgeModel: MessagePreviewModel? = nil,
        dragId: String?,
        contentState: WidgetContentState = .hasData,
        defaultExpanded: Bool = true,
        menuItems: [WidgetMenuItem] = [.changeType, .removeSystemWidget],
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
        self.contentState = contentState
        self.onCreateObjectTap = onCreateObjectTap
        self.onHeaderTap = onHeaderTap
        self.content = content()
        self._model = State(
            initialValue: WidgetContainerViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                spaceInfo: spaceInfo,
                expectedMenuItems: menuItems,
                defaultExpanded: defaultExpanded,
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
                            if let badgeModel, badgeModel.hasVisibleCounters {
                                HStack(spacing: 4) {
                                    if badgeModel.hasUnreadReactions {
                                        HeartBadge(style: badgeModel.reactionStyle)
                                    }
                                    if badgeModel.mentionCounter > 0 {
                                        MentionBadge(style: badgeModel.mentionCounterStyle)
                                    }
                                    if badgeModel.shouldShowUnreadCounter {
                                        CounterView(
                                            count: badgeModel.unreadCounter,
                                            style: badgeModel.unreadCounterStyle
                                        )
                                    }
                                }
                                .opacity(shouldHideChatBadges ? 0 : 1)
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
        .onChange(of: contentState) { oldValue, newValue in
            let animated = oldValue != .loading
            model.updateExpanded(contentState: newValue, animated: animated)
        }
    }

    @ViewBuilder
    private var menuItemsView: some View {
        createObjectMenuButton
        WidgetCommonActionsMenuView(
            items: model.menuItems,
            widgetBlockId: model.widgetBlockId,
            widgetObject: model.widgetObject,
            homeState: model.homeState,
            output: model.output,
            targetObjectId: model.targetObjectId,
            accountInfo: model.spaceInfo
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
