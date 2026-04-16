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
                                HeartBadge(style: model.muted ? .muted : .highlighted)
                            }
                            if model.hasMentions {
                                MentionBadge(style: model.muted ? .muted : .highlighted)
                            }
                            if model.messageCount > 0 {
                                CounterView(count: model.messageCount, style: model.muted ? .muted : .highlighted)
                            }
                            Image(asset: .X18.pin)
                                .renderingMode(.template)
                                .foregroundStyle(Color.Control.secondary)
                                .padding(.leading, 12)
                                .padding(.trailing, 16)
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
