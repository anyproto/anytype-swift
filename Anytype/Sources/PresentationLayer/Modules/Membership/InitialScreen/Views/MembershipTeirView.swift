import SwiftUI
import Services


struct MembershipTeirView: View {
    let tier: MembershipTier
    let onTap: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: tier.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(tier.title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(tier.subtitle, style: .caption1Regular, color: .Text.primary)
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
                    tier.gradient
                }
            }
        )
        .cornerRadius(16, style: .continuous)
    }
    
    var info: some View {
        switch tier {
        case .explorer:
            AnytypeText(Loc.justEMail, style: .bodySemibold, color: .Text.primary)
        case .builder:
            AnytypeText("$99 ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(Loc.perYear, style: .caption1Regular, color: .Text.primary)
        case .coCreator:
            AnytypeText("$299 ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(Loc.perXYears(3), style: .caption1Regular, color: .Text.primary)
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            MembershipTeirView(tier: .explorer) {  }
            MembershipTeirView(tier: .builder) {  }
            MembershipTeirView(tier: .coCreator) {  }
        }
    }
}
