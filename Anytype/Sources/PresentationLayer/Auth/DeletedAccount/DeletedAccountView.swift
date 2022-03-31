import SwiftUI

struct DeletedAccountView: View {
    let progress: DeletionProgress
    @StateObject var model = DeletedAccountViewModel()
    
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
            clock
            Spacer.fixedHeight(19)
            title
            Spacer.fixedHeight(11)
            AnytypeText("Pending deletion text".localized, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(14)
            SettingsButton(text: "Cancel deletion", textColor: .System.red) { model.cancel() }
            SettingsButton(text: "Logout and clear data", textColor: .System.red) { model.logOut() }
        }
    }
    
    private var title: some View {
        let dayLiteral = progress.daysToDeletion > 1 ? "days".localized : "day".localized
        let localizedPrefix = "This account is planned for deletion in".localized
        let text = "\(localizedPrefix) \(progress.daysToDeletion) \(dayLiteral)"
        return AnytypeText(text, style: .heading, color: .textPrimary)
    }
    
    @State private var clockProgress: CGFloat = 0
    private var clock: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color.strokePrimary, lineWidth: 2)
                    .frame(width: 52, height: 52)
                Clock(progress: clockProgress)
                    .fill(Color.System.red)
                    .frame(width: 36, height: 36)
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(dampingFraction: 0.5).speed(0.4)) {
                clockProgress = progress.deletionProgress
            }
        }
    }
}
