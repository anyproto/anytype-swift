import Foundation
import SwiftUI
import Services
import AnytypeCore

struct ChatHeaderView: View {

    @State private var model: ChatHeaderViewModel
    @Namespace private var glassNamespace

    init(
        spaceId: String,
        chatId: String,
        onTapOpenWidgets: @escaping () -> Void,
        onTapOpenSpaceSettings: @escaping () -> Void,
        onTapAddMembers: @escaping (() -> Void)
    ) {
        _model = State(initialValue: ChatHeaderViewModel(
            spaceId: spaceId,
            chatId: chatId,
            onTapOpenWidgets: onTapOpenWidgets,
            onTapOpenSpaceSettings: onTapOpenSpaceSettings,
            onTapAddMembers: onTapAddMembers
        ))
    }

    var body: some View {
        NavigationHeader(
            navigationButtonType: .back,
            isTitleInteractive: true
        ) {
            titleView
        } rightContent: {
            HStack(spacing: 8) {
                addMembersButton
                avatarButton
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .animation(.bouncy, value: model.showLoading)
        .animation(.bouncy, value: model.muted)
        .animation(.bouncy, value: model.showAddMembersButton)
    }

    private var titleView: some View {
        Button {
            model.tapOpenWidgets()
        } label: {
            HStack(spacing: 6) {
                if model.showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                }
                AnytypeText(model.title, style: .uxTitle1Semibold)
                    .lineLimit(1)
                if model.muted {
                    Image(asset: .X18.muted)
                        .foregroundStyle(Color.Text.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var addMembersButton: some View {
        if model.showAddMembersButton {
            Button {
                model.tapAddMembers()
            } label: {
                Image(systemName: "person.fill.badge.plus")
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
            }
            .glassEffectInteractiveIOS26(in: Circle())
            .glassEffectIDIOS26("addMembers", in: glassNamespace)
        }
    }

    @ViewBuilder
    private var avatarButton: some View {
        Group {
            if FeatureFlags.chatSettings {
                if model.isMultiChatSpace {
                    ObjectSettingsMenuContainer(
                        objectId: model.chatId,
                        spaceId: model.spaceId,
                        output: nil
                    ) {
                        IconView(icon: model.icon)
                            .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                    }
                } else {
                    Button {
                        model.tapOpenSpaceSettings()
                    } label: {
                        IconView(icon: model.icon)
                            .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                    }
                }
            } else {
                Button {
                    model.tapOpenWidgets()
                } label: {
                    IconView(icon: model.icon)
                        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                }
            }
        }
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("avatar", in: glassNamespace)
    }
}
