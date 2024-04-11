import SwiftUI
import Services
import Combine


struct MembershipModuleView: View {
    @Environment(\.openURL) private var openURL
    
    private let membership: MembershipStatus
    private let tiers: [MembershipTier]
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        membership: MembershipStatus,
        tiers: [MembershipTier],
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.membership = membership
        self.tiers = tiers
        self.onTierTap =  onTierTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack {
                    Spacer.fixedHeight(40)
                    AnytypeText(Loc.Membership.Ad.title, style: .riccioneTitle)
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular)
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                    Spacer.fixedHeight(32)
                    
                    baners
                    MembershipTierListView(userMembership: membership, tiers: tiers) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onTierTap($0)
                    }
                    .padding(.vertical, 32)
                    
                    legal
                }
            }
        }
    }
    
    var baners: some View {
        TabView {
            MembershipBannerView(
                title: Loc.Membership.Banner.title1,
                subtitle: Loc.Membership.Banner.subtitle1,
                image: .Membership.banner1,
                gradient: .green
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title2,
                subtitle: Loc.Membership.Banner.subtitle2,
                image: .Membership.banner2,
                gradient: .yellow
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title3,
                subtitle: Loc.Membership.Banner.subtitle3,
                image: .Membership.banner3,
                gradient: .pink
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title4,
                subtitle: Loc.Membership.Banner.subtitle4,
                image: .Membership.banner4,
                gradient: .purple
            )
        }
        .tabViewStyle(.page)
        .frame(height: 300)
    }
    
    var legal: some View {
        VStack {
            MembershipLegalButton(text: Loc.Membership.Legal.details) {
                openURL(URL(string: "https://anytype.io/pricing")!)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.privacy) { 
                openURL(URL(string: "https://anytype.io/app_privacy")!)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.terms) { 
                openURL(URL(string: "https://anytype.io/terms_of_use")!)
            }
            
            Button {
                let mailLink = MailUrl(
                    to: "license@anytype.io",
                    subject: Loc.Membership.Email.subject,
                    body: Loc.Membership.Email.body
                )
                guard let mailUrl = mailLink.url else { return }
                openURL(mailUrl)
            } label: {
                AnytypeText(
                    "\(Loc.Membership.Legal.wouldYouLike) ",
                    style: .caption1Regular
                ).foregroundColor(.Text.primary) +
                AnytypeText(
                    Loc.Membership.Legal.letUsKnow,
                    style: .caption1Regular
                ).foregroundColor(.Text.primary).underline()
            }
        }
    }
}

#Preview {
    NavigationView {
        MembershipModuleView(
            membership: .empty,
            tiers: [],
            onTierTap: { _ in }
        )
    }
}
