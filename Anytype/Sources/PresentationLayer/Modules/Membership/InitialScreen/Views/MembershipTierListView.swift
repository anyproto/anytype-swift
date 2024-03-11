import SwiftUI
import Services


struct MembershipTierListView: View {
    let userTier: MembershipTier?
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(userTier.availableTiers) { tier in
                        MembershipTeirView(tierToDisplay: tier, userTier: userTier) {
                            onTierTap(tier)
                        }
                        .id(tier)
                    }
                    
                    Spacer.fixedWidth(0)
                }
            }
            .onAppear {
                scrollView.scrollTo(MembershipTier.builder, anchor: .center)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            MembershipTierListView(userTier: nil) { _ in }
            MembershipTierListView(userTier: .explorer) { _ in }
            MembershipTierListView(userTier: .builder) { _ in }
            MembershipTierListView(userTier: .coCreator) { _ in }
        }
    }
}
