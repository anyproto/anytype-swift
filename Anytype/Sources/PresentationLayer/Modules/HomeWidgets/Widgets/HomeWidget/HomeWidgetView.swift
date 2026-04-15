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
                            Image(asset: .CustomIcons.home)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.Control.secondary)
                                .padding(.trailing, 12)
                        }
                    },
                    onTap: {
                        model.onHeaderTap()
                    }
                )
            },
            content: { EmptyView() }
        )
        .if(model.canSetHomepage) {
            $0.contextMenu {
                Button {
                    model.onChangeHomeTap()
                } label: {
                    Label(Loc.HomepagePicker.changeHome, systemImage: "house")
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
