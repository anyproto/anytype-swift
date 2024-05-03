import SwiftUI
import Services
import AnytypeCore


struct MembershipTierSelectionView: View {
    @StateObject private var model: MembershipTierSelectionViewModel
    @State private var safariUrl: URL?

    
    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTier,
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
        
    ) {
        _model = StateObject(
            wrappedValue: MembershipTierSelectionViewModel(
                userMembership: userMembership,
                tierToDisplay: tierToDisplay,
                onSuccessfulPurchase: onSuccessfulPurchase
            )
        )
    }
    
    var body: some View {
        scrollView
        .safariSheet(url: $safariUrl)
        .task {
            await model.onAppear()
        }
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                MembershipTierInfoView(tier: model.tierToDisplay)
                sheet
                    .cornerRadius(12, corners: .top)
                    .background(sheetBackground)
            }
        }
        .hideScrollIndicatorLegacy()
    }
    
    var sheet: some View {
        Group {
            switch model.state {
            case .owned:
                MembershipOwnerInfoSheetView()
            case .pending:
                MembershipPendingInfoSheetView(membership: model.userMembership)
            case .unowned:
                switch model.tierToDisplay.paymentType {
                case .appStore(let product):
                    MembershipNameSheetView(tier: model.tierToDisplay, anyName: model.userMembership.anyName, product: product, onSuccessfulPurchase: model.onSuccessfulPurchase)
                case .external(let info):
                    VStack {
                        StandardButton(Loc.moreInfo, style: .primaryLarge) {
                            AnytypeAnalytics.instance().logClickMembership(type: .moreInfo)
                            safariUrl = info.paymentUrl
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 34)
                    }
                    .background(Color.Background.primary)
                    .cornerRadius(16, corners: .top)
                case nil:
                    Rectangle().hidden().onAppear {
                        anytypeAssertionFailure(
                            "No unowned view for empty payment info",
                            info: ["Tier": String(reflecting: model.tierToDisplay)]
                        )
                    }
                }
            }
        }
    }
    
    // To mimic sheet overlay style
    var sheetBackground: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .Shape.tertiary, location: 0.5),
                Gradient.Stop(color: .Background.primary, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    TabView {
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockExplorer),
            tierToDisplay: .mockExplorer,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: nil),
            tierToDisplay: .mockExplorer,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockExplorer),
            tierToDisplay: .mockBuilder,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockBuilder, anyName: .mock),
            tierToDisplay: .mockBuilder,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockBuilder, anyName: .mock),
            tierToDisplay: .mockCoCreator,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockCoCreator, anyName: .mock),
            tierToDisplay: .mockCoCreator,
            onSuccessfulPurchase: { _ in }
        )
    }.tabViewStyle(.page)
}
