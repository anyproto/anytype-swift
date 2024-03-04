import SwiftUI

struct MembershipTierListView: View {
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Spacer.fixedWidth(0)
                MembershipTeirView(
                    title: Loc.Membership.Explorer.title,
                    subtitle: Loc.Membership.Explorer.info,
                    image: .Membership.tierExplorer,
                    gradient: .teal
                ) {
                    onTierTap(.explorer)
                }
                
                MembershipTeirView(
                    title: Loc.Membership.Builder.title,
                    subtitle: Loc.Membership.Builder.info,
                    image: .Membership.tierBuilder,
                    gradient: .blue
                ) {
                    onTierTap(.builder)
                }
                
                MembershipTeirView(
                    title: Loc.Membership.CoCreator.title,
                    subtitle: Loc.Membership.CoCreator.info,
                    image: .Membership.tierCocreator,
                    gradient: .red
                ) {
                    onTierTap(.coCreator)
                }
                Spacer.fixedWidth(0)
            }
        }
    }
}

#Preview {
    MembershipTierListView { _ in }
}
