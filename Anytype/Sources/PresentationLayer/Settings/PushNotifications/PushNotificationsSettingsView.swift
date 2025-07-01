import SwiftUI

struct PushNotificationsSettingsView: View {
    
    @StateObject private var model: PushNotificationsSettingsViewModel
    
    init() {
        _model = StateObject(wrappedValue: PushNotificationsSettingsViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.notifications)
            if let mode = model.status {
                content(with: mode)
            }
            Spacer()
        }
        .onAppear() {
            model.onAppear()
        }
        .task {
            await model.subscribeToSystemSettingsChanges()
        }
    }
    
    private func content(with status: PushNotificationsSettingsStatus) -> some View {
        VStack(spacing: 0) {
            DisabledPushNotificationsBannerView()
            switch status {
            case .authorized:
                notificationsStatusRow(enabled: true)
            case .denied:
                notificationsStatusRow(enabled: false)
            case .notDetermined:
                EmptyView()
            }
        }
        .padding(.horizontal, 12)
    }
    
    private func notificationsStatusRow(enabled: Bool) -> some View {
        HStack(spacing: 0) {
            AnytypeText(Loc.PushNotifications.Settings.Status.title, style: .previewTitle1Regular)
                .foregroundColor(.Text.primary)
            
            Spacer()
            
            Circle()
                .fill(enabled ? Color.System.green : Color.System.red)
                .frame(width: 10, height: 10)
            
            Spacer.fixedWidth(8)
            
            AnytypeText(enabled ? Loc.enabled : Loc.disabled, style: .previewTitle1Regular)
                .foregroundColor(.Text.secondary)
            
            if !enabled {
                Spacer.fixedWidth(8)
                Image(asset: .X18.webLink)
                    .foregroundColor(.Control.active)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 4)
        .newDivider()
        .fixTappableArea()
        .applyIf(!enabled) {
            $0.onTapGesture {
                model.openSettings()
            }
        }
    }
}
