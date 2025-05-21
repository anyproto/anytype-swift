import SwiftUI
import Services
import AnytypeCore
import StoreKit


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
        content
        .safariSheet(url: $safariUrl)
        .task {
            await model.onAppear()
        }
    }
    
    private var content: some View {
        ZStack {
            scrollView
            dragOverlay
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
        .scrollIndicators(.never)
    }
    
    var dragOverlay: some View {
        VStack {
            // fixTappableArea() do not work inside TabView
            Color.black.opacity(0.0001).frame(height: 100)
            Spacer()
        }
    }
    
    var sheet: some View {
        Group {
            switch model.state {
            case nil:
                EmptyView()
            case .owned:
                MembershipOwnerInfoSheetView()
            case .pending:
                MembershipPendingInfoSheetView(membership: model.userMembership)
            case .unowned(let availablitiy):
                switch availablitiy {
                case .appStore(let product):
                    MembershipNameSheetView(tier: model.tierToDisplay, anyName: model.userMembership.anyName, product: product, onSuccessfulPurchase: model.onSuccessfulPurchase)
                case .external(let url):
                    if FeatureFlags.hideWebPayments {
                        notAvaliableOnAppStore
                    } else {
                        moreInfoButton(url: url)
                    }
                }
            }
        }
    }
    
    func moreInfoButton(url: URL) -> some View {
        VStack {
            StandardButton(Loc.moreInfo, style: .primaryLarge) {
                AnytypeAnalytics.instance().logClickMembership(type: .moreInfo)
                safariUrl = url
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 34)
        }
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
    }
    
    var notAvaliableOnAppStore: some View {
        VStack {
            AnytypeText(Loc.Membership.unavailable, style: .uxTitle2Regular)
                .frame(maxWidth: .infinity)
                .foregroundColor(.Text.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 34)
        }
        .background(Color.Background.primary)
        .cornerRadius(16, corners: .top)
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
            userMembership: .mock(tier: .mockStarter),
            tierToDisplay: .mockStarter,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: nil),
            tierToDisplay: .mockStarter,
            onSuccessfulPurchase: { _ in }
        )
        MembershipTierSelectionView(
            userMembership: .mock(tier: .mockStarter),
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
