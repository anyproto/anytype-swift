import SwiftUI

struct MembershipModuleView: View {
    @StateObject var model: MembershipModuleViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                DragIndicator()
                Spacer.fixedHeight(40)
                
                AnytypeText(Loc.Membership.Ad.title, name: .inter, size: 48, weight: .light)
                    .foregroundStyle(Color.Text.primary)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular, color: .Text.primary)
                    .padding(.horizontal, 60)
                    .multilineTextAlignment(.center)
                Spacer.fixedHeight(32)
                
                baners
                tiers
                legal
            }
        }
    }
    
    var tiers: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Spacer.fixedWidth(0)
                MembershipTeirView()
                MembershipTeirView()
                MembershipTeirView()
                Spacer.fixedWidth(0)
            }
        }
        .padding(.vertical, 32)
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
                model.onLegalDetailsTap()
            }
            MembershipLegalButton(text: Loc.Membership.Legal.privacy) { 
                model.onLegalPrivacyTap()
            }
            MembershipLegalButton(text: Loc.Membership.Legal.terms) { 
                model.onLegalTermsTap()
            }
            
            Button {
                model.onLetUsKnowTap()
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
            model: MembershipModuleViewModel(
                urlOpener: DI.preview.uihelpersDI.urlOpener()
            )
        )
    }
}
