import SwiftUI

struct MembershipTierListView: View {
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(MembershipTier.allCases) { tier in
                        MembershipTeirView(
                            title: tier.title,
                            subtitle: tier.subtitle,
                            image: tier.smallIcon,
                            gradient: tier.gradient
                        ) {
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
    MembershipTierListView { _ in }
}
