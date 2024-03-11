import SwiftUI
import Services


struct MembershipTeirView: View {
    let tierToDisplay: MembershipTier
    let currentTier: MembershipTier?
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
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            StandardButton(Loc.learnMore, style: .primaryMedium, action: onTap)
            Spacer.fixedHeight(20)
        }
        .if(currentTier == tierToDisplay) {
            $0.overlay(alignment: .topTrailing) {
                if currentTier == tierToDisplay {
                    AnytypeText(Loc.current, style: .relation3Regular, color: .Text.primary)
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 3, trailing: 8))
                        .border(11, color: .Text.primary)
                        .padding(.top, 16)
                }
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
    
    var info: some View {
        Group {
            switch tierToDisplay {
            case .explorer:
                if currentTier == tierToDisplay {
                    AnytypeText(Loc.foreverFree, style: .caption1Regular, color: .Text.primary)
                } else {
                    AnytypeText(Loc.justEMail, style: .bodySemibold, color: .Text.primary)
                }
            case .builder:
                if currentTier == tierToDisplay {
                    AnytypeText(Loc.validUntilDate("%Date%"), style: .caption1Regular, color: .Text.primary)
                } else {
                    AnytypeText("$99 ", style: .bodySemibold, color: .Text.primary) +
                    AnytypeText(Loc.perYear, style: .caption1Regular, color: .Text.primary)
                }
            case .coCreator:
                if currentTier == tierToDisplay {
                    AnytypeText(Loc.validUntilDate("%Date%"), style: .caption1Regular, color: .Text.primary)
                } else {
                    AnytypeText("$299 ", style: .bodySemibold, color: .Text.primary) +
                    AnytypeText(Loc.perXYears(3), style: .caption1Regular, color: .Text.primary)
                }
            }
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            MembershipTeirView(tierToDisplay: .explorer, currentTier: .explorer) {  }
            MembershipTeirView(tierToDisplay: .builder, currentTier: .explorer) {  }
            MembershipTeirView(tierToDisplay: .coCreator, currentTier: .explorer) {  }
        }
    }
}
