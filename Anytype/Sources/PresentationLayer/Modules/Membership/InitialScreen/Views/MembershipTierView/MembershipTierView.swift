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
            .onTapGesture {
                model.onTap()
            }
            .task {
                model.updateState()
            }
            .onChange(of: model.userMembership) { _ in 
                model.updateState()
            }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: model.tierToDisplay.smallIcon)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(model.tierToDisplay.name, style: .bodySemibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(model.tierToDisplay.description, style: .caption1Regular)
                .foregroundColor(.Text.primary)
                .minimumScaleFactor(0.8)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            StandardButton(Loc.learnMore, style: .primaryXSmallStretched, action: model.onTap)
            Spacer.fixedHeight(20)
        }
        .if(model.state.isOwned) {
            $0.overlay(alignment: .topTrailing) { ownershipOverlay }
        }
        
        .fixTappableArea()
        .padding(.horizontal, 16)
        .frame(width: 192, height: 296)
        .background(backgroundView)
        .cornerRadius(16, style: .continuous)
    }
    
    private var info: some View  {
        Group {
            switch model.state {
            case .owned:
                expirationText
            case .pending:
                AnytypeText(Loc.pending, style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            case .unowned:
                MembershipPricingView(tier: model.tierToDisplay)
            case nil:
                EmptyView()
            }
        }
    }
    
    private var expirationText: some View {
        Group {
            switch model.userMembership.dateEnds {
            case .never:
                AnytypeText(Loc.foreverFree, style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            case .date:
                AnytypeText(Loc.validUntilDate(model.userMembership.formattedDateEnds), style: .caption1Regular)
                    .foregroundColor(.Text.primary)
            }
        }
    }
    
    private var ownershipOverlay: some View {
        AnytypeText(Loc.current, style: .relation3Regular)
            .foregroundColor(.Text.primary)
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 3, trailing: 8))
            .border(11, color: .Text.primary)
            .padding(.top, 16)
    }
    
    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                Color.Shape.tertiary
            } else {
                model.tierToDisplay.gradient
            }
        }
    }
}

#Preview("No tier") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: nil, status: .pending)
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockStarter, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Pending starter") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockStarter, status: .pending)
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockStarter, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}

#Preview("Active starter") {
    ScrollView(.horizontal) {
        MockView {
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockStarter)
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockStarter, onTap: { })
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
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockBuilder)
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockStarter, onTap: { })
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
            MembershipStatusStorageMock.shared._status = .mock(tier: .mockCustom, paymentMethod: .methodCrypto)
        } content: {
            HStack {
                MembershipTierView(tierToDisplay: .mockStarter, onTap: { })
                MembershipTierView(tierToDisplay: .mockBuilder, onTap: { })
                MembershipTierView(tierToDisplay: .mockCoCreator, onTap: { })
                MembershipTierView(tierToDisplay: .mockCustom, onTap: { })
            }
        }
    }
}
