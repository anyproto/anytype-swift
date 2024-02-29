import SwiftUI

struct MembershipModuleView: View {
    @StateObject var model: MembershipModuleViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                AnytypeText(Loc.Membership.Ad.title, name: .inter, size: 48, weight: .medium).foregroundStyle(Color.Text.primary)
                AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular, color: .Text.primary)
                
                // Temp
                Rectangle().foregroundStyle(Color.green).frame(idealHeight: 300)
                    .overlay(alignment: .center) {
                        AnytypeText("Co-create with us", style: .bodyRegular, color: .Text.primary)
                    }
                Rectangle().foregroundStyle(Color.red).frame(idealHeight: 300)
                    .overlay(alignment: .center) {
                        AnytypeText("Tiers list", style: .bodyRegular, color: .Text.primary)
                    }
                
                legal
            }
        }
    }
    
    var legal: some View {
        VStack {
            MembershipLegalButton(text: Loc.Membership.Legal.details) { }
            MembershipLegalButton(text: Loc.Membership.Legal.privacy) { }
            MembershipLegalButton(text: Loc.Membership.Legal.terms) { }
            
            Button {} label: {
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
    MembershipModuleView(
        model: MembershipModuleViewModel()
    )
}
