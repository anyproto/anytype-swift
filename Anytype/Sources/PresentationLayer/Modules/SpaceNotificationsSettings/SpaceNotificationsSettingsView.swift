import Foundation
import SwiftUI

struct SpaceNotificationsSettingsView: View {

    @State private var model: SpaceNotificationsSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: SpaceNotificationsSettingsModuleData) {
        _model = State(initialValue: SpaceNotificationsSettingsViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.notifications)
            content
            Spacer()
        }
        .task {
            await model.startSubscriptions()
        }
        .background(Color.Background.secondary)
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DisabledPushNotificationsBannerView()

            ListSectionHeaderView(title: Loc.Space.Notifications.Settings.header)
                .padding(.horizontal, 16)

            ForEach(SpaceNotificationsSettingsMode.allCases, id: \.self) { mode in
                modeView(mode)
            }
            .padding(.horizontal, 16)

            if model.chatsWithCustomNotifications.isNotEmpty {
                ListSectionHeaderView(title: Loc.Space.Notifications.Settings.CustomChats.header)
                    .padding(.horizontal, 16)

                ForEach(model.chatsWithCustomNotifications) { chat in
                    customChatRow(chat)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func customChatRow(_ chat: CustomChatNotification) -> some View {
        HStack(spacing: 12) {
            IconView(icon: chat.icon)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(chat.title, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                AnytypeText(chat.mode.titleShort, style: .relation3Regular)
                    .foregroundStyle(Color.Text.secondary)
            }

            Spacer()

            AsyncButton {
                try await model.onRemoveCustomSetting(chatId: chat.chatId)
            } label: {
                Image(asset: .X24.close)
                    .foregroundStyle(Color.Control.secondary)
            }
        }
        .frame(height: 72)
        .if(chat.id != model.chatsWithCustomNotifications.last?.id) {
            $0.newDivider()
        }
    }
    
    private func modeView(_ mode: SpaceNotificationsSettingsMode) -> some View {
        AsyncButton {
            try await model.onModeChange(mode)
        } label: {
            HStack(spacing: 0) {
                AnytypeText(mode.title, style: .previewTitle1Regular)
                    .foregroundStyle(model.disabledStatus() ? Color.Text.tertiary : Color.Text.primary)
                Spacer()
                if !model.disabledStatus(), model.mode == mode {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Control.primary)
                }
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .if(!mode.isLast) {
                $0.newDivider()
            }
        }
        .disabled(model.disabledStatus())
    }
}
