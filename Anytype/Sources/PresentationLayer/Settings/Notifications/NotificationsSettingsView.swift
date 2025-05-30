import SwiftUI

struct NotificationsSettingsView: View {
    
    @StateObject private var model: NotificationsSettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        _model = StateObject(wrappedValue: NotificationsSettingsViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.notifications)
            if let mode = model.mode {
                content(with: mode)
            }
            Spacer()
        }
        .task {
            await model.checkStatus()
        }
        .task(item: model.requestAuthorizationId) { _ in
            await model.requestAuthorization()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .background(Color.Background.secondary)
    }
    
    private func content(with mode: NotificationsSettingsMode) -> some View {
        VStack(spacing: 0) {
            switch mode {
            case .authorized:
                notificationsStatusRow(enabled: true)
            case .denied:
                disabledAlert(with: Loc.openSettings) {
                    model.openSettings()
                }
                notificationsStatusRow(enabled: false)
            case .notDetermined:
                disabledAlert(with: Loc.PushNotifications.RequestAlert.primaryButton) {
                    model.enableNotificationsTap()
                }
            }
        }
        .padding(.horizontal, 12)
        
    }
    
    private func disabledAlert(with title: String, onTap: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Image(asset: .PushNotifications.bell)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(Loc.PushNotifications.Settings.DisabledAlert.title, style: .bodySemibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            AnytypeText(Loc.PushNotifications.Settings.DisabledAlert.description, style: .uxTitle2Regular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            StandardButton(
                title,
                style: .primarySmall,
                action: onTap
            )
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
        .padding(.horizontal, 20)
        .background(Color.Shape.tertiary)
        .cornerRadius(12, style: .continuous)
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
            }
        }
        .padding(.vertical, 14)
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
