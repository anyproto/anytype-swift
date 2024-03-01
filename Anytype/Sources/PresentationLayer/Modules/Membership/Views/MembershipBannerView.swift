import SwiftUI

struct MembershipBannerView: View {
    let title: String
    let subtitle: String
    let image: ImageAsset
    let gradient: FadingGradient
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Image(asset: image)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(24)
            AnytypeText(title, style: .bodyRegular, color: .Text.primary)
                .lineLimit(1)
            Spacer.fixedHeight(6)
            AnytypeText(
                subtitle,
                style: .relation2Regular,
                color: .Text.primary
            ).multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(
            Group {
                if colorScheme == .dark {
                    Color.Shape.tertiary
                } else {
                    gradient.gradientView()
                }
            }
        )
    }
}

#Preview {
    MembershipBannerView(
        title: "Invest in Connectivity",
        subtitle: "Our software is free by design, but we thrive on the network that connects us all. Support us, and you're investing in the very infrastructure that keeps us united",
        image: .membershipBanner1,
        gradient: .green
    )
}
