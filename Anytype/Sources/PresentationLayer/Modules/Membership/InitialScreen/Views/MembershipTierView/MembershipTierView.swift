import SwiftUI
import Services


struct MembershipTierView: View {
    @StateObject private var model: MembershipTierViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        _model = StateObject(
            wrappedValue: MembershipTierViewModel(
                tierToDisplay: tierToDisplay,
                onTap: onTap
            )
        )
    }

    
    var body: some View {
        content
            .task {
                model.updateState()
            }
            .onChange(of: model.userMembership) { _ in 
                model.updateState()
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: model.tierToDisplay.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(model.tierToDisplay.name, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(model.tierToDisplay.subtitle, style: .caption1Regular)
                .foregroundColor(.Text.primary)
                .minimumScaleFactor(0.8)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            StandardButton(Loc.learnMore, style: .primaryMedium, action: model.onTap)
                .disabled(model.state.isPending)
            Spacer.fixedHeight(20)
        }
        .if(model.state.isOwned) {
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
            if !model.state.isPending {
                model.onTap()
            }
        }
        .padding(.horizontal, 16)
        .frame(width: 192, height: 296)
        .background(
            Group {
                if colorScheme == .dark {
                    Color.Shape.tertiary
                } else {
                    model.tierToDisplay.gradient
                }
            }
        )
        .cornerRadius(16, style: .continuous)
    }
    
    var info: some View  {
        Group {
            switch model.state {
            case .owned:
                expirationText
            case .pending:
                AnytypeText(Loc.pending, style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            case .unowned:
                MembershipPricingView(tier: model.tierToDisplay)
            }
        }
    }
    
    var expirationText: some View {
        Group {
            switch model.tierToDisplay.type {
            case .explorer:
                return AnytypeText(Loc.foreverFree, style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            case .builder, .coCreator, .custom:
                return AnytypeText(Loc.validUntilDate(model.userMembership.formattedDateEnds), style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            }
        }
    }
}

#Preview("No tier") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = MembershipStatus(
                tier: nil,
                status: .pending,
                dateEnds: .tomorrow,
                paymentMethod: .methodStripe,
                anyName: .mockEmpty
            )
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockExplorer, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Pending explorer") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = MembershipStatus(
                tier: .mockExplorer,
                status: .pending,
                dateEnds: .tomorrow,
                paymentMethod: .methodStripe,
                anyName: .mockEmpty
            )
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockExplorer, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Active explorer") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = MembershipStatus(
                tier: .mockExplorer,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodInappApple,
                anyName: .mockEmpty
            )
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockExplorer, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Active builder") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = MembershipStatus(
                tier: .mockBuilder,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodStripe,
                anyName: .mockEmpty
            )
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockExplorer, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Active custom") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = MembershipStatus(
                tier: .mockCustom,
                status: .active,
                dateEnds: .tomorrow,
                paymentMethod: .methodCrypto,
                anyName: .mockEmpty
            )
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockExplorer, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}
