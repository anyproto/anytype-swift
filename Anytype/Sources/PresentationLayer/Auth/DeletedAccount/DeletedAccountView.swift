import SwiftUI

struct DeletedAccountView: View {
    
    @StateObject private var viewModel: DeletedAccountViewModel
    
    init(deadline: Date) {
        _viewModel = StateObject(wrappedValue: DeletedAccountViewModel(deadline: deadline))
    }
    
    var body: some View {
        ZStack {
            CoverGradientView(data: CoverGradient.sky.data).ignoresSafeArea()
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
        .background(Color.Background.primary)
        .cornerRadius(16.0)
    }
    
    private var mainView: some View {
        VStack(alignment: .leading, spacing: 0) {
            clock
            Spacer.fixedHeight(19)
            AnytypeText(viewModel.title, style: .heading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(11)
            AnytypeText(Loc.pendingDeletionText, style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(14)
            SettingsButton(text: Loc.cancelDeletion, textColor: .Pure.red) { viewModel.cancel() }
            SettingsButton(text: Loc.logoutAndClearData, textColor: .Pure.red) { viewModel.logOut() }
        }
    }
    
    @State private var clockProgress: CGFloat = 0
    private var clock: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color.Shape.primary, lineWidth: 2)
                    .frame(width: 52, height: 52)
                Clock(progress: clockProgress)
                    .fill(Color.Pure.red)
                    .frame(width: 36, height: 36)
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(dampingFraction: 0.7).speed(0.4)) {
                clockProgress = viewModel.deletionProgress
            }
        }
    }
}
