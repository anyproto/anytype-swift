import SwiftUI

struct MembershipTierSelectionView: View {
    let tier: MembershipTier
    
    var body: some View {
        AnytypeText(title, style: .title, color: .Text.primary)
    }
    
    private var title: String {
        switch tier {
        case .explorer:
            return Loc.Membership.Explorer.title
        case .builder:
            return Loc.Membership.Builder.title
        case .coCreator:
            return Loc.Membership.CoCreator.title
        }
    }
}

#Preview {
    MembershipTierSelectionView(tier: .builder)
}
