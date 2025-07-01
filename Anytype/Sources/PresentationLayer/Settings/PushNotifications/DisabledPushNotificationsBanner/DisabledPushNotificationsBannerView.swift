import SwiftUI

struct DisabledPushNotificationsBannerView: View {
    
    @StateObject private var model: DisabledPushNotificationsBannerViewModel
    
    init() {
        _model = StateObject(wrappedValue: DisabledPushNotificationsBannerViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch model.status {
            case .notDetermined:
                content(with: Loc.PushNotifications.RequestAlert.primaryButton, onTap: { model.enableNotificationsTap() })
            case .denied:
                content(with: Loc.openSettings, onTap: { model.openSettings() })
            case .authorized, .none:
                EmptyView()
            }
        }
        .task {
            await model.subscribeToSystemSettingsChanges()
        }
        .task(item: model.requestAuthorizationId) { _ in
            await model.requestAuthorization()
        }
    }
    
    private func content(with title: String, onTap: @escaping () -> Void) -> some View {
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
        .background(Color.Shape.transperentTertiary)
        .cornerRadius(12, style: .continuous)
    }
}
