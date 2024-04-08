import SwiftUI
import Services


struct MembershipTeirView: View {
    let tierToDisplay: MembershipTier
    let userMembership: MembershipStatus
    let onTap: () -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isPending: Bool {
        userMembership.tier?.type == tierToDisplay.type && userMembership.status != .active
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: tierToDisplay.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(tierToDisplay.name, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(tierToDisplay.subtitle, style: .caption1Regular)
                .foregroundColor(.Text.primary)
                .minimumScaleFactor(0.8)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            actionButton
            Spacer.fixedHeight(20)
        }
        .if(userMembership.tier?.type == tierToDisplay.type) {
            $0.overlay(alignment: .topTrailing) {
                AnytypeText(Loc.current, style: .relation3Regular)
                    .foregroundColor(.Text.primary)
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
            if case .custom = tierToDisplay.type {
                StandardButton(Loc.About.contactUs, style: .primaryMedium, action: onTap)
            } else {
                StandardButton(Loc.learnMore, style: .primaryMedium, action: onTap)
            }
        }.disabled(isPending)
    }
    
    var info: some View  {
        Group {
            if userMembership.tier?.type == tierToDisplay.type {
                if userMembership.status == .active {
                    expirationText
                } else {
                    AnytypeText(Loc.pending, style: .caption1Regular)
                        .foregroundColor(.Text.primary)
                }
            } else {
                MembershipPricingView(tier: tierToDisplay)
            }
        }
    }
    
    var expirationText: some View {
        Group {
            switch tierToDisplay.type {
            case .explorer:
                return AnytypeText(Loc.foreverFree, style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            case .builder, .coCreator, .custom:
                return AnytypeText(Loc.validUntilDate(userMembership.formattedDateEnds), style: .caption1Regular)
                    .foregroundColor(.Text.primary)
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
