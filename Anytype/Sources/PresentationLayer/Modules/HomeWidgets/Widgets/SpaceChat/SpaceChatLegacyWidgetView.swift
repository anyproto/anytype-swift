import Foundation
import SwiftUI
import AnytypeCore

struct SpaceChatLegacyWidgetView: View {
    
    @StateObject private var model: SpaceChatLegacyWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(data: WidgetSubmoduleData) {
        self._homeState = data.homeState
        self._model = StateObject(wrappedValue: SpaceChatLegacyWidgetViewModel(data: data))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: $homeState,
            allowMenuContent: true,
            allowContent: false,
            removeAction: {
                model.onDeleteWidgetTap()
            },
            header: {
                LinkWidgetDefaultHeader(
                    title: Loc.chat,
                    icon: .asset(.X24.chat),
                    rightAccessory: {
                        HStack(spacing: 4) {
                            if model.hasMentions {
                                MentionBadge(style: model.muted ? .muted : .highlighted)
                            }
                            if model.messageCount > 0 {
                                CounterView(count: model.messageCount, style: model.muted ? .muted : .highlighted)
                            }
                        }
                    },
                    onTap: {
                        model.onHeaderTap()
                    }
                )
            },
            menu: {
                WidgetCommonActionsMenuView(
                    items: [.remove],
                    widgetBlockId: model.widgetBlockId,
                    widgetObject: model.widgetObject,
                    homeState: homeState,
                    output: model.output
                )
            },
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
