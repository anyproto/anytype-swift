import Foundation
import SwiftUI
import Services

struct ChatHeaderView: View {

    @StateObject private var model: ChatHeaderViewModel

    init(
        spaceId: String,
        chatId: String,
        onTapOpenWidgets: @escaping () -> Void,
        onTapAddMembers: @escaping (() -> Void)
    ) {
        self._model = StateObject(wrappedValue: ChatHeaderViewModel(
            spaceId: spaceId,
            chatId: chatId,
            onTapOpenWidgets: onTapOpenWidgets,
            onTapAddMembers: onTapAddMembers
        ))
    }
    
    var body: some View {
        PageNavigationHeader {
            ExpandedTapAreaButton {
                model.tapOpenWidgets()
            } label: {
                HStack(spacing: 6) {
                    if model.showLoading {
                        CircleLoadingView(.Text.primary)
                            .frame(width: 18, height: 18)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Spacer.fixedWidth(18)
                    }
                    AnytypeText(model.title, style: .uxTitle1Semibold)
                        .lineLimit(1)
                    if model.muted {
                        Image(asset: .X18.muted)
                            .foregroundColor(.Text.primary)
                    } else {
                        Spacer.fixedWidth(18)
                    }
                }
            }
        } rightView: {
            HStack(spacing: 16) {
                if model.showAddMembersButton {
                    ExpandedTapAreaButton {
                        model.tapAddMembers()
                    } label: {
                        Image(systemName: "person.fill.badge.plus")
                            .foregroundColor(.Control.transparentSecondary)
                            .frame(width: 28, height: 28)
                    }
                }
                if model.showWidgetsButton {
                    ExpandedTapAreaButton {
                        model.tapOpenWidgets()
                    } label: {
                        IconView(icon: model.icon)
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
        .background {
            HomeBlurEffectView(direction: .topToBottom)
                .ignoresSafeArea()
        }
        .task {
            await model.startSubscriptions()
        }
        .animation(.default, value: model.showLoading)
    }
}
