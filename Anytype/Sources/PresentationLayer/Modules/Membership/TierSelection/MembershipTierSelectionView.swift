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
            if model.userMembership.tier?.id == model.tierToDisplay.id {
                MembershipOwnerInfoSheetView(membership: model.userMembership)
                EmptyView()
            } else {
                switch model.tierToDisplay.id {
                case .explorer:
                    MembershipEmailSheetView { email, subscribeToNewsletter in
                        try await model.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
                    }
                case .builder, .coCreator:
                    MembershipNameSheetView(tier: model.tierToDisplay, anyName: model.userMembership.anyName)
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
    TabView {
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: .mockExplorer,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .mockExplorer,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: nil,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .mockExplorer,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: .mockExplorer,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .mockBuilder,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: .mockBuilder,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .mockBuilder,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: .mockBuilder,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .mockCoCreator,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tier: .mockCoCreator,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .mockCoCreator,
            showEmailVerification: { _ in }
        )
    }.tabViewStyle(.page)
}
