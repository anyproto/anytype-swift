import SwiftUI
import Services


struct MembershipTierListView: View {
    let currentTier: MembershipTier?
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(currentTier.availableTiers) { tier in
                        MembershipTeirView(tierToDisplay: tier, currentTier: currentTier) {
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
            MembershipTierListView(currentTier: nil) { _ in }
            MembershipTierListView(currentTier: .explorer) { _ in }
            MembershipTierListView(currentTier: .builder) { _ in }
            MembershipTierListView(currentTier: .coCreator) { _ in }
        }
    }
}
