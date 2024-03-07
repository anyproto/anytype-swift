import SwiftUI

struct MembershipTeirView: View {
    let title: String
    let subtitle: String
    let image: ImageAsset
    let gradient: MembershipTeirGradient
    let onTap: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: image)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(subtitle, style: .caption1Regular, color: .Text.primary)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            StandardButton(Loc.learnMore, style: .primaryMedium, action: onTap)
            Spacer.fixedHeight(20)
        }
        .fixTappableArea()
        .onTapGesture(perform: onTap)
        .padding(.horizontal, 16)
        .frame(width: 192, height: 296)
        .background(
            Group {
                if colorScheme == .dark {
                    Color.Shape.tertiary
                } else {
                    gradient
                }
            }
        )
        .cornerRadius(16, style: .continuous)
    }
    
    var info: some View {
        AnytypeText(Loc.justEMail, style: .bodySemibold, color: .Text.primary)
    }
}

#Preview {
    MembershipTeirView(
        title: Loc.Membership.Explorer.title,
        subtitle: Loc.Membership.Explorer.subtitle,
        image: .Membership.tierExplorerSmall,
        gradient: .teal
    ) {  }
}
