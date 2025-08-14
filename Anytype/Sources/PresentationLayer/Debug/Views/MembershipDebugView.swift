import SwiftUI
import Services
import StoreKit

fileprivate struct DebugTierData {
    let title: String
    let subtitle: String
    let image: ImageAsset
}


struct MembershipDebugView: View {
    @Injected(\.membershipService)
    private var service: any MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var storage: any MembershipStatusStorageProtocol
    @Injected(\.storeKitService)
    private var storeKitService: any StoreKitServiceProtocol
    
    @State private var tiers: [DebugTierData] = []
    @State private var transactions: [StoreKit.Transaction] = []
    @State private var toastBarData: ToastBarData?
    
    @State private var refundId: StoreKit.Transaction.ID?
    @State private var showRefund = false
    @State private var showMembership = false
    
    var body: some View {
        ScrollView {
            membershipInfo
            openMembershipButton
            tiersInfo
            transactionsView
        }
        .frame(maxWidth: .infinity)
        .background(storage.currentStatus.tier?.gradient.ignoresSafeArea())
        
        .snackbar(toastBarData: $toastBarData)
        .refundRequestSheet(for: refundId ?? 0, isPresented: $showRefund)
        
        .sheet(isPresented: $showMembership) { 
            MembershipCoordinator()
        }
        
        .task {
            await loadTiers()
            await loadTransactions()
        }
    }
    
    @MainActor
    private var membershipInfo: some View {
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
    
    private var openMembershipButton: some View {
        StandardButton("Open membership screen", style: .primaryLarge) {
            showMembership = true
        }
        .padding()
    }
    
    private var tiersInfo: some View {
        DisclosureGroup(
            content: {
                VStack(alignment: .leading) {
                    ForEach(tiers, id: \.title) { tier in
                        tierInfo(tier).newDivider()
                    }
                }
            },
            label: {
                AnytypeText("All Tiers info", style: .heading)
                    .foregroundColor(.Text.primary)
                    .padding()
            }
        ).padding()
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
    
    private var transactionsView: some View {
        DisclosureGroup(
            content: {
                if transactions.isNotEmpty {
                    VStack(alignment: .leading) {
                        ForEach(transactions) { transaction in
                            transactionView(transaction: transaction)
                        }
                    }
                } else {
                    AnytypeText("No transactions 🫵😵‍💫", style: .heading)
                        .foregroundColor(.Text.secondary)
                        .padding()
                }
            },
            label: {
                AnytypeText("Transactions", style: .heading)
                    .foregroundColor(.Text.primary)
                    .padding()
            }
        ).padding()
    }
    
    private func transactionView(transaction: StoreKit.Transaction) -> some View {
        VStack(alignment: .center) {
            AnytypeText("\(transaction.productID)", style: .bodyRegular)
            AnytypeText("\(transaction.ownershipType.rawValue)", style: .bodyRegular)
            if #available(iOS 17.0, *) {
                AnytypeText("Transaction reason: \(transaction.reason.rawValue)", style: .bodyRegular)
            }
            AnytypeText("Purchase date: \(transaction.purchaseDate.description)", style: .caption1Medium)
            if let expirationDate = transaction.expirationDate {
                AnytypeText("Expires: \(expirationDate.description)", style: .caption1Medium)
            }
            AnytypeText("Environment: \(transaction.environment.rawValue)", style: .caption1Medium)
            if let revocationReason = transaction.revocationReason {
                AnytypeText("Revocation reason: \(revocationReason.localizedDescription)", style: .caption1Medium)
                    .foregroundStyle(Color.Pure.red)
            }
            if let revocationDate = transaction.revocationDate {
                AnytypeText("Revocation data: \(revocationDate)", style: .caption1Medium)
                    .foregroundStyle(Color.Pure.red)
            }
            StandardButton("Copy to clipboard", style: .secondaryLarge) {
                UIPasteboard.general.string = transaction.debugDescription
                toastBarData = ToastBarData("Copied debug info to clipboard")
            }
            StandardButton("Refund", style: .warningLarge) {
                refundId = transaction.id
                showRefund = true
            }
        }
        .padding()
        .background(Color.Control.tertiary.gradient)
        .cornerRadius(18, style: .continuous)
    }
    
    // MARK: - Logic
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
    
    func loadTransactions() async {
        for await transaction in Transaction.all {
            (try? checkVerified(transaction)).flatMap {
                transactions.append($0)
            }
        }
    }
    
    private func checkVerified<T>(_ verificationResult: VerificationResult<T>) throws -> T {
        switch verificationResult {
        case .unverified(_, let verificationError):
            throw verificationError
        case .verified(let signedType):
            return signedType
        }
    }
}

#Preview {
    MembershipDebugView()
}
