import SwiftUI

struct DeletedAccountView: View {
    let progress: DeletionProgress
    private let service = ServiceLocator.shared.authService()
    
    var body: some View {
        ZStack {
            Gradients.mainBackground()
            contentView
        }
        .navigationBarHidden(true)
    }
    
    private var contentView: some View {
        VStack() {
            Spacer()
            bottomSheet
                .horizontalReadabilityPadding(20)
                .padding(.bottom, 20)
        }
    }
    
    private var bottomSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainView
                .padding(EdgeInsets(top: 23, leading: 20, bottom: 10, trailing: 20))
        }
        .background(Color.backgroundPrimary)
        .cornerRadius(16.0)
    }
    
    private var mainView: some View {
        VStack(alignment: .leading, spacing: 0) {
            clock(progress: progress.deletionProgress)
            Spacer.fixedHeight(19)
            title
            Spacer.fixedHeight(11)
            AnytypeText("Pending deletion text".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(14)
            cancelButton
            SettingsButton(text: "Logout and clear data", textColor: .System.red) {
                guard service.logout(removeData: true) else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return
                }
                windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
            }
        }
    }
    
    private var cancelButton: some View {
        SettingsButton(text: "Cancel deletion", textColor: .System.red) {
            guard let status = service.restoreAccount() else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            if case .active = status {
                windowHolder?.startNewRootView(HomeViewAssembly().createHomeView())
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
        }
    }
    
    private var title: some View {
        let dayLiteral = progress.daysToDeletion > 1 ? "days".localized : "day".localized
        let localizedPrefix = "This account is planned for deletion in".localized
        let text = "\(localizedPrefix) \(progress.daysToDeletion) \(dayLiteral)"
        return AnytypeText(text, style: .heading, color: .textPrimary)
    }
    
    private func clock(progress: CGFloat) -> some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color.strokePrimary, lineWidth: 2)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(Color.System.red, lineWidth: 2)
                    .frame(width: 36, height: 36)
                    .rotationEffect(Angle(degrees: -90))
            }
            Spacer()
        }
    }
}
