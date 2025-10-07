import Foundation
import SwiftUI
import AnytypeCore

struct SpaceChatWidgetView: View {
    
    @StateObject private var model: SpaceChatWidgetViewModel
    
    init(data: SpaceChatWidgetData) {
        self._model = StateObject(wrappedValue: SpaceChatWidgetViewModel(data: data))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: .constant(.readwrite),
            allowMenuContent: false,
            allowContent: false,
            removeAction: nil,
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
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
