import Foundation
import SwiftUI
import AnytypeCore

struct HomeWidgetView: View {

    @State private var model: HomeWidgetViewModel

    init(data: HomepageWidgetViewData) {
        _model = State(initialValue: HomeWidgetViewModel(data: data))
    }

    var body: some View {
        LinkWidgetViewContainer(
            isExpanded: .constant(false),
            dragId: nil,
            homeState: .constant(.readwrite),
            allowContent: false,
            allowContextMenuItems: model.canSetHomepage,
            header: {
                LinkWidgetDefaultHeader(
                    title: model.title,
                    icon: model.icon,
                    rightAccessory: {
                        HStack(spacing: 4) {
                            if model.hasUnreadReactions {
                                HeartBadge(style: model.notificationMode.reactionCounterStyle)
                            }
                            if model.hasMentions {
                                MentionBadge(style: model.notificationMode.mentionCounterStyle)
                            }
                            if model.shouldShowUnreadCounter {
                                CounterView(count: model.messageCount, style: model.notificationMode.unreadCounterStyle)
                            }
                            Image(asset: .CustomIcons.home)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color.Control.secondary)
                                .frame(width: 18, height: 18)
                        }
                    },
                    onTap: {
                        model.onHeaderTap()
                    }
                )
            },
            menu: {
                Button {
                    model.onChangeHomeTap()
                } label: {
                    Label(Loc.HomepagePicker.changeHome, systemImage: "house")
                }
            },
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
