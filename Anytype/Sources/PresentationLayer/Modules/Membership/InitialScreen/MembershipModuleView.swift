import SwiftUI
import Services


struct MembershipModuleView: View {
    @StateObject private var model: MembershipModuleViewModel
    @Environment(\.openURL) private var openURL
    
    init(
        userTier: MembershipTier?,
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        _model = StateObject(wrappedValue: MembershipModuleViewModel(
            userTier: userTier,
            onTierTap: onTierTap
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack {
                    Spacer.fixedHeight(40)
                    AnytypeText(Loc.Membership.Ad.title, style: .riccioneTitle, color: .Text.primary)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular, color: .Text.primary)
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                    Spacer.fixedHeight(32)
                    
                    baners
                    MembershipTierListView(userTier: model.userTier) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        model.onTierTap(tier: $0)
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
                    style: .caption1Regular,
                    color: .Text.primary
                ) +
                AnytypeText(
                    Loc.Membership.Legal.letUsKnow,
                    style: .caption1Regular,
                    color: .Text.primary
                ).underline()
            }
        }
    }
}

#Preview {
    NavigationView {
        MembershipModuleView(
            userTier: .builder,
            onTierTap: { _ in }
        )
    }
}
