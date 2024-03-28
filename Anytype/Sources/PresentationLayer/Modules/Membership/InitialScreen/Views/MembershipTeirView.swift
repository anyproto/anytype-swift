import SwiftUI
import Services


struct MembershipTeirView: View {
    let tierToDisplay: MembershipTier
    let userMembership: MembershipStatus
    let onTap: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isPending: Bool {
        userMembership.tier?.id == tierToDisplay.id && userMembership.status != .active
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: tierToDisplay.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(tierToDisplay.name, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(tierToDisplay.subtitle, style: .caption1Regular, color: .Text.primary)
                .minimumScaleFactor(0.8)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            actionButton
            Spacer.fixedHeight(20)
        }
        .if(userMembership.tier?.id == tierToDisplay.id) {
            $0.overlay(alignment: .topTrailing) {
                AnytypeText(Loc.current, style: .relation3Regular, color: .Text.primary)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 3, trailing: 8))
                    .border(11, color: .Text.primary)
                    .padding(.top, 16)
            }
        }
        .fixTappableArea()
        .onTapGesture {
            if !isPending {
                onTap()
            }
        }
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
        Group {
            if case .custom = tierToDisplay.id {
                StandardButton(Loc.About.contactUs, style: .primaryMedium, action: onTap)
            } else {
                StandardButton(Loc.learnMore, style: .primaryMedium, action: onTap)
            }
        }.disabled(isPending)
    }
    
    var info: some View  {
        Group {
            if userMembership.tier?.id == tierToDisplay.id {
                if userMembership.status == .active {
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
        switch tierToDisplay.id {
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
            switch tierToDisplay.id {
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
                tierToDisplay: .mockExplorer,
                userMembership: MembershipStatus(
                    tier: nil,
                    status: .unknown,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockExplorer,
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockExplorer,
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockBuilder,
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockBuilder,
                userMembership: MembershipStatus(
                    tier: .mockBuilder,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockCoCreator,
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
            MembershipTeirView(
                tierToDisplay: .mockCustom,
                userMembership: MembershipStatus(
                    tier: .mockCustom,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                )
            ) {  }
        }
    }
}
