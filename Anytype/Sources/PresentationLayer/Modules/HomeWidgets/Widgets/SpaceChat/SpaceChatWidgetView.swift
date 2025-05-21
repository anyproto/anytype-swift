import Foundation
import SwiftUI

struct SpaceChatWidgetView: View {
    
    @StateObject private var model: SpaceChatWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(data: WidgetSubmoduleData) {
        self._homeState = data.homeState
        self._model = StateObject(wrappedValue: SpaceChatWidgetViewModel(spaceId: data.workspaceInfo.accountSpaceId, output: data.output))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: $homeState,
            allowMenuContent: false,
            allowContent: false,
            removeAction: nil,
            header: {
                LinkWidgetDefaultHeader(
                    title: Loc.chat,
                    icon: .X24.chat,
                    rightAccessory: {
                        HStack(spacing: 4) {
                            if model.hasMentions {
                                MentionBadge()
                            }
                            if model.messageCount > 0 {
                                CounterView(count: model.messageCount)
                            }
                        }
                    },
                    onTap: {
                        model.onHeaderTap()
                    }
                )
            },
            menu: { },
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
