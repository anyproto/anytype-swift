import Foundation
import SwiftUI
import Services

struct ChatHeaderView: View {

    @State private var model: ChatHeaderViewModel
    private let settingsOutput: (any ObjectSettingsCoordinatorOutput)?

    init(
        spaceId: String,
        chatId: String,
        settingsOutput: (any ObjectSettingsCoordinatorOutput)?,
        onTapOpenWidgets: @escaping () -> Void,
        onTapOpenSpaceSettings: @escaping () -> Void
    ) {
        _model = State(initialValue: ChatHeaderViewModel(
            spaceId: spaceId,
            chatId: chatId,
            onTapOpenWidgets: onTapOpenWidgets,
            onTapOpenSpaceSettings: onTapOpenSpaceSettings
        ))
        self.settingsOutput = settingsOutput
    }

    var body: some View {
        NavigationHeader(
            navigationButtonType: .back,
            isTitleInteractive: true
        ) {
            titleView
        } rightContent: {
            moreButton
        }
        .task {
            await model.startSubscriptions()
        }
        .animation(.bouncy, value: model.showLoading)
        .animation(.bouncy, value: model.muted)
        .animation(.bouncy, value: model.isArchived)
        .snackbar(toastBarData: $model.toastBarData)
    }

    private var titleView: some View {
        Button {
            model.tapOpenWidgets()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                IconView(icon: model.icon)
                    .frame(width: 32, height: 32)
                Spacer.fixedWidth(8)
                if model.showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                    Spacer.fixedWidth(4)
                }
                if model.isOneToOne {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            AnytypeText(model.title, style: .uxTitle2Semibold)
                                .lineLimit(1)
                            if model.hasMembership {
                                Image(asset: .X18.membershipBadge)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            if model.muted {
                                Image(asset: .X18.muted)
                                    .foregroundStyle(Color.Control.transparentSecondary)
                            }
                            if model.isArchived {
                                Image(asset: .X18.delete)
                                    .foregroundStyle(Color.Control.transparentSecondary)
                            }
                        }
                        AnytypeText(model.anytypeName, style: .relation3Regular)
                            .foregroundStyle(Color.Text.transparentSecondary)
                            .lineLimit(1)
                    }
                } else {
                    AnytypeText(model.title, style: .uxTitle2Semibold)
                        .lineLimit(1)
                    if model.muted {
                        Spacer.fixedWidth(4)
                        Image(asset: .X18.muted)
                            .foregroundStyle(Color.Control.transparentSecondary)
                    }
                    if model.isArchived {
                        Spacer.fixedWidth(4)
                        Image(asset: .X18.delete)
                            .foregroundStyle(Color.Control.transparentSecondary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 6)
        }
        .frame(height: NavigationHeaderConstants.height)
    }

    @ViewBuilder
    private var moreButton: some View {
        Group {
            if model.isMultiChatSpace {
                ObjectSettingsMenuContainer(
                    objectId: model.chatId,
                    spaceId: model.spaceId,
                    output: settingsOutput
                ) {
                    Image(asset: .X24.more)
                        .foregroundStyle(Color.Control.primary)
                        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                }
            } else {
                Menu {
                    Button {
                        model.tapOpenSpaceSettings()
                    } label: {
                        Label {
                            Text(Loc.Chat.channelSettings)
                        } icon: {
                            Image(asset: .X24.spaceSettings)
                        }
                    }

                    NotificationModeMenu(
                        currentMode: model.notificationMode,
                        onModeChange: model.changeNotificationMode
                    )
                } label: {
                    Image(asset: .X24.more)
                        .foregroundStyle(Color.Control.primary)
                        .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                }
            }
        }
        .glassEffectInteractiveIOS26(in: Circle())
    }
}
