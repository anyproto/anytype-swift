import SwiftUI
import Services

fileprivate struct DebugTierData {
    let title: String
    let subtitle: String
    let image: ImageAsset
}


struct MembershipDebugView: View {
    @Injected(\.membershipService)
    private var service: MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var storage: MembershipStatusStorageProtocol
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    
    @State private var tiers: [DebugTierData] = []
    
    var body: some View {
        ScrollView {
            membershipInfo
            tiersInfo
        }
        .frame(maxWidth: .infinity)
        .background(storage.currentStatus.tier?.gradient.ignoresSafeArea())
        .task {
            await loadTiers()
        }
    }
    
    func loadTiers() async {
        guard let tiersData = try? await service.getTiers(noCache: true) else { return }
        
        tiers = await tiersData
            .asyncMap { tier in
                switch tier.paymentType {
                case .appStore(let info):
                    let isPurchased = try? await storeKitService.isPurchased(product: info.product)
                    let isPurchasedString: String
                    if let isPurchased {
                        isPurchasedString = isPurchased ? "Purchased ✅" : "Not Purchased ❌"
                    } else {
                        isPurchasedString = "No data, Error ⚠️"
                    }
                    
                    return DebugTierData(title: tier.name, subtitle: "AppStore subscription:\n\(isPurchasedString)", image: tier.smallIcon)
                case .external:
                    return DebugTierData(title: tier.name, subtitle: "Stripe payment", image: tier.smallIcon)
                case .none:
                    return DebugTierData(title: tier.name, subtitle: "No payment", image: tier.smallIcon)
                }
            }
            .compactMap { $0 }
    }
    
    @MainActor
    var membershipInfo: some View {
        VStack(alignment: .center) {
            AnytypeText("Current tier", style: .heading)
            if let mediumIcon = storage.currentStatus.tier?.mediumIcon {
                Image(asset: mediumIcon)
            }
            AnytypeText(storage.currentStatus.debugDescription, style: .codeBlock)
            Spacer()
        }
        .padding()
    }
    
    private var tiersInfo: some View {
        VStack(alignment: .leading) {
            AnytypeText("All Tiers info", style: .heading).padding()
            
            ForEach(tiers, id: \.title) { tier in
                tierInfo(tier).newDivider()
            }
        }
    }
    
    private func tierInfo(_ tier: DebugTierData) -> some View {
        HStack {
            Image(asset: tier.image)
            VStack(alignment: .leading) {
                AnytypeText(tier.title, style: .codeBlock)
                AnytypeText(tier.subtitle, style: .codeBlock)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MembershipDebugView()
}
