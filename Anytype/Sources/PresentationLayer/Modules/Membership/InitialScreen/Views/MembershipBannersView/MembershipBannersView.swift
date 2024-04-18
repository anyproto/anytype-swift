import SwiftUI

struct MembershipBannersView: View {
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var index = 0
    
    var body: some View {
        TabView(selection: $index) {
            MembershipBannerView(
                title: Loc.Membership.Banner.title1,
                subtitle: Loc.Membership.Banner.subtitle1,
                image: .Membership.banner1,
                gradient: .green
            ).tag(0)
            MembershipBannerView(
                title: Loc.Membership.Banner.title2,
                subtitle: Loc.Membership.Banner.subtitle2,
                image: .Membership.banner2,
                gradient: .yellow
            ).tag(1)
            MembershipBannerView(
                title: Loc.Membership.Banner.title3,
                subtitle: Loc.Membership.Banner.subtitle3,
                image: .Membership.banner3,
                gradient: .pink
            ).tag(2)
            MembershipBannerView(
                title: Loc.Membership.Banner.title4,
                subtitle: Loc.Membership.Banner.subtitle4,
                image: .Membership.banner4,
                gradient: .purple
            ).tag(3)
        }
        .tabViewStyle(.page)
        .frame(height: 300)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                index = (index + 1) % 4
            }
        }
    }
}

#Preview {
    MembershipBannersView()
}
