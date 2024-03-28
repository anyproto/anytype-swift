import SwiftUI
import Services


struct MembershipTierSelectionView: View {
    @StateObject private var model: MembershipTierSelectionViewModel
    
    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTierId,
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
            if model.userMembership.tier?.id == model.tierToDisplay {
                MembershipOwnerInfoSheetView(membership: model.userMembership)
            } else {
                switch model.tierToDisplay {
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
                tierId: .explorer,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .explorer,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tierId: nil,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .explorer,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tierId: .explorer,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: ""
            ),
            tierToDisplay: .builder,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tierId: .builder,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .builder,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tierId: .builder,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .coCreator,
            showEmailVerification: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: MembershipStatus(
                tierId: .coCreator,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCard,
                anyName: "SonyaBlade"
            ),
            tierToDisplay: .coCreator,
            showEmailVerification: { _ in }
        )
    }.tabViewStyle(.page)
}
