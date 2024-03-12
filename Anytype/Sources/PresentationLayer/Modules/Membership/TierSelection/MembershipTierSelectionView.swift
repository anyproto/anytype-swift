import SwiftUI
import Services


struct MembershipTierSelectionView: View {
    @StateObject private var model: MembershipTierSelectionViewModel
    
    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTier,
        showEmailVerification: @escaping (EmailVerificationData) -> ()
    ) {
        _model = StateObject(
            wrappedValue: MembershipTierSelectionViewModel(
                userMembership: userMembership,
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
            if model.userMembership.tier == model.tierToDisplay {
                MembershipOwnerInfoSheetView(membership: model.userMembership)
            } else {
                switch model.tierToDisplay {
                case .explorer:
                    MembershipEmailSheetView { email, subscribeToNewsletter in
                        try await model.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
                    }
                case .builder, .coCreator:
                    MembershipNameSheetView(tier: model.tierToDisplay)
                case .custom:
                    EmptyView() // TBD in future updates
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
            userMembership: MembershipStatus(
                tier: .builder,
                status: .statusActive,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard
            ),
            tierToDisplay: .builder,
            showEmailVerification: { _ in }
        )
    }
}
