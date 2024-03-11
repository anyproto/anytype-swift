import SwiftUI
import Services


struct MembershipTierSelectionView: View {
    @Binding var userTier: MembershipTier?
    
    @StateObject private var model: MembershipTierSelectionViewModel
    
    init(
        userTier: Binding<MembershipTier?>,
        tierToDisplay: MembershipTier,
        showEmailVerification: @escaping (EmailVerificationData) -> ()
    ) {
        _userTier = userTier
        _model = StateObject(
            wrappedValue: MembershipTierSelectionViewModel(
                tierToDisplay: tierToDisplay,
                showEmailVerification: showEmailVerification
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MembershipTierInfoView(tier: model.tierToDisplay)
                sheet
                    .cornerRadius(12, corners: .top)
                    .background(sheetBackground)
            }
        }
    }
    
    var sheet: some View {
        Group {
            if let userTier = userTier, userTier == model.tierToDisplay {
                MembershipOwnerInfoSheetView(tier: userTier)
            } else {
                switch model.tierToDisplay {
                case .explorer:
                    MembershipEmailSheetView { email, subscribeToNewsletter in
                        try await model.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
                    }
                case .builder, .coCreator:
                    MembershipNameSheetView(tier: model.tierToDisplay)
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
    ScrollView {
        MembershipTierSelectionView(
            userTier: .constant(.builder),
            tierToDisplay: .builder,
            showEmailVerification: { _ in }
        )
    }
}
