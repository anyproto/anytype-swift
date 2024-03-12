import SwiftUI
import Services


struct MembershipTeirView: View {
    let tierToDisplay: MembershipTier
    let userMembership: MembershipStatus
    let onTap: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: tierToDisplay.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(tierToDisplay.title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(tierToDisplay.subtitle, style: .caption1Regular, color: .Text.primary)
                .minimumScaleFactor(0.8)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            actionButton
            Spacer.fixedHeight(20)
        }
        .if(userMembership.tier == tierToDisplay) {
            $0.overlay(alignment: .topTrailing) {
                AnytypeText(Loc.current, style: .relation3Regular, color: .Text.primary)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 3, trailing: 8))
                    .border(11, color: .Text.primary)
                    .padding(.top, 16)
            }
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
                    tierToDisplay.gradient
                }
            }
        )
        .cornerRadius(16, style: .continuous)
    }
    
    var actionButton: some View {
        if case .custom = tierToDisplay {
            StandardButton(Loc.About.contactUs, style: .primaryMedium, action: onTap)
        } else {
            StandardButton(Loc.learnMore, style: .primaryMedium, action: onTap)
        }
    }
    
    var info: some View  {
        Group {
            if userMembership.tier == tierToDisplay {
                if userMembership.status == .statusActive {
                    expirationText
                } else {
                    AnytypeText(Loc.pending, style: .caption1Regular, color: .Text.primary)
                }
            } else {
                priceText
            }
        }
    }
    
    var priceText: some View {
        switch tierToDisplay {
        case .explorer:
            AnytypeText(Loc.justEMail, style: .bodySemibold, color: .Text.primary)
        case .builder:
            AnytypeText("$99 ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(Loc.perYear, style: .caption1Regular, color: .Text.primary)
        case .coCreator:
            AnytypeText("$299 ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(Loc.perXYears(3), style: .caption1Regular, color: .Text.primary)
        case .custom:
            AnytypeText(Loc.detailsUponRequest, style: .caption1Regular, color: .Text.primary)
        }
    }
    
    var expirationText: some View {
        Group {
            switch tierToDisplay {
            case .explorer:
                return AnytypeText(Loc.foreverFree, style: .caption1Regular, color: .Text.primary)
            case .builder, .coCreator, .custom:
                return AnytypeText(Loc.validUntilDate(userMembership.formattedDateEnds), style: .caption1Regular, color: .Text.primary)
            }
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            MembershipTeirView(
                tierToDisplay: .explorer,
                userMembership: MembershipStatus(
                    tier: nil,
                    status: .statusUnknown,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .explorer,
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusPending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .explorer,
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusActive,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .builder,
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusPending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .builder,
                userMembership: MembershipStatus(
                    tier: .builder,
                    status: .statusActive,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .coCreator,
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusActive,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .custom(id: 0),
                userMembership: MembershipStatus(
                    tier: .custom(id: 0),
                    status: .statusActive,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard
                )
            ) {  }
        }
    }
}
