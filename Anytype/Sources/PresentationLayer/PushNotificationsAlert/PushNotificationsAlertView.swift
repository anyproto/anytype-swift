import SwiftUI

struct PushNotificationsAlertView: View {
    
    @StateObject private var model: PushNotificationsAlertViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: PushNotificationsAlertData) {
        _model = StateObject(wrappedValue: PushNotificationsAlertViewModel(data: data))
    }
    
    var body: some View {
        content
            .onAppear {
                model.onAppear()
            }
            .task(item: model.requestAuthorizationId) { _ in
                await model.requestAuthorization()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .background(Color.Background.secondary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            Spacer.fixedHeight(20)
            
            text
            
            Spacer.fixedHeight(20)

            buttons
            
            Spacer.fixedHeight(16)
        }
    }
    
    private var header: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.Gradients.Push.violetStart,
                        Color.Gradients.Push.violetEnd
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            
            headerContent
            
        }
        .frame(height: 232)
    }
    
    private var headerContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            notification
            
            Spacer.fixedHeight(16)
            
            Image(asset: .PushNotifications.screenTop)
        }
    }
    
    private var notification: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(8)
                Image(asset: AppIconManager.shared.currentIcon.previewAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .cornerRadius(9, style: .continuous)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(Loc.PushNotifications.RequestAlert.notificationTitle, style: .previewTitle2Medium)
                    .foregroundColor(.PushNotifications.text)
                    .lineLimit(1)
                
                Spacer.fixedHeight(5)
                
                hiddenLine
                
                Spacer.fixedHeight(10)
                
                hiddenLine
                    .padding(.trailing, 32)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .frame(width: 280)
        .background(Color.PushNotifications.background)
        .cornerRadius(20, style: .continuous)
    }
    
    private var hiddenLine: some View {
        Capsule()
            .fill(Color.PushNotifications.hiddenText)
            .frame(height: 8)
            .frame(maxWidth: .infinity)
    }
    
    
    private var text: some View {
        VStack(spacing: 8) {
            AnytypeText(Loc.PushNotifications.RequestAlert.title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            AnytypeText(Loc.PushNotifications.RequestAlert.description, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    private var buttons: some View {
        VStack(spacing: 8) {
            StandardButton(
                Loc.PushNotifications.RequestAlert.primaryButton,
                style: .primaryLarge,
                action: {
                    model.enablePushesTap()
                }
            )
            
            StandardButton(
                Loc.PushNotifications.RequestAlert.secondaryButton,
                style: .secondaryLarge,
                action: {
                    model.laterTap()
                }
            )
        }
        .padding(.horizontal, 16)
    }
}
