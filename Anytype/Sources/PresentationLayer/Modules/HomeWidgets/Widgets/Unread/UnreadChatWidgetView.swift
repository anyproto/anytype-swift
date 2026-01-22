import Foundation
import SwiftUI
import AnytypeCore

struct UnreadChatWidgetView: View {
    let data: UnreadChatWidgetData

    @State private var model: UnreadChatWidgetViewModel

    init(data: UnreadChatWidgetData) {
        self.data = data
        self._model = State(initialValue: UnreadChatWidgetViewModel(data: data))
    }

    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: .constant(.readonly),
            allowContent: false,
            allowContextMenuItems: false,
            header: {
                LinkWidgetDefaultHeader(
                    title: model.name,
                    icon: model.icon,
                    rightAccessory: {
                        HStack(spacing: 4) {
                            if model.hasMentions {
                                MentionBadge(style: model.muted ? .muted : .highlighted)
                            }
                            if model.unreadCounter > 0 {
                                CounterView(count: model.unreadCounter, style: model.muted ? .muted : .highlighted)
                            }
                        }
                    },
                    onTap: {
                        model.onHeaderTap()
                    }
                )
            },
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
