import SwiftUI

struct DisabledPushNotificationsAlertView: View {
    
    @StateObject private var model: DisabledPushNotificationsAlertViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        _model = StateObject(wrappedValue: DisabledPushNotificationsAlertViewModel())
    }
    
    var body: some View {
        content
            .onAppear {
                model.onAppear()
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }
            .background(Color.Background.secondary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            Spacer.fixedHeight(16)
            
            AnytypeText(Loc.PushNotifications.DisabledAlert.title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(8)
            
            AnytypeText(Loc.PushNotifications.DisabledAlert.description, style: .uxTitle2Regular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(20)

            StandardButton(
                Loc.openSettings,
                style: .primaryLarge,
                action: {
                    model.openSettings()
                }
            )
            
            Spacer.fixedHeight(10)
            
            StandardButton(
                Loc.PushNotifications.DisabledAlert.Skip.button,
                style: .secondaryLarge,
                action: {
                    model.skip()
                }
            )
            
            Spacer.fixedHeight(16)
        }
        .padding(.horizontal, 16)
    }
}
