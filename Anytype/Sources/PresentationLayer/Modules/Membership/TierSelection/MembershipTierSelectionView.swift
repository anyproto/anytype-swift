import SwiftUI

struct MembershipTierSelectionView: View {
    @State var model: MembershipTierSelectionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MembershipTierInfoView(tier: model.tier)
                sheet
            }
            .background(Color.Shape.tertiary)
        }
    }
    
    var sheet: some View {
        Group {
            switch model.tier {
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

#Preview {
    MembershipTierSelectionView(
        model: MembershipTierSelectionViewModel(
            tier: .explorer,
            membershipService: DI.preview.serviceLocator.membershipService()
        )
    )
}
