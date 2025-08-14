import Foundation
import SwiftUI

struct SpaceNotificationsSettingsView: View {
    
    @StateObject private var model: SpaceNotificationsSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self._model = StateObject(wrappedValue: SpaceNotificationsSettingsViewModel(data: data))
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
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DisabledPushNotificationsBannerView()
            
            ListSectionHeaderView(title: Loc.PushNotifications.Settings.Status.title)
                .padding(.horizontal, 16)
                
            ForEach(SpaceNotificationsSettingsMode.allCases, id: \.self) { mode in
                modeView(mode)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func modeView(_ mode: SpaceNotificationsSettingsMode) -> some View {
        AsyncButton {
            try await model.onModeChange(mode)
        } label: {
            HStack(spacing: 0) {
                AnytypeText(mode.title, style: .previewTitle1Regular)
                    .foregroundColor(model.disabledStatus() ? .Text.tertiary : .Text.primary)
                Spacer()
                if !model.disabledStatus(), model.mode == mode {
                    Image(asset: .X24.tick)
                        .foregroundColor(.Control.primary)
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
