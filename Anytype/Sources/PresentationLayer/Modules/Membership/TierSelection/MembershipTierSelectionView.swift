import SwiftUI


struct MembershipTierSelectionView: View {
    @StateObject var model: MembershipTierSelectionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MembershipTierInfoView(tier: model.tierToDisplay)
                sheet
                    .cornerRadius(12, corners: .top)
                    .background(sheetBackground)
            }
        }
        .task {
            model.onAppear()
        }
    }
    
    var sheet: some View {
        Group {
            if let userTier = model.userTier, userTier == model.tierToDisplay {
                MembershipOwnerInfoSheetView(tier: userTier)
            } else {
                switch model.tierToDisplay {
                case .explorer:
                    MembershipEmailSheetView { email, subscribeToNewsletter in
                        try await model.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
                    }
                case .builder:
                    Color.blue.frame(height: 300)
                case .coCreator:
                    Color.red.frame(height: 300)
                }
            }
        }
    }
    
    // To mimic sheet overlay style
    var sheetBackground: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .Shape.tertiary, location: 0.5),
                Gradient.Stop(color: .Background.primary, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    MembershipTierSelectionView(
        model: MembershipTierSelectionViewModel(
            tierToDisplay: .explorer,
            membershipService: DI.preview.serviceLocator.membershipService(),
            showEmailVerification: { _ in }
        )
    )
}
