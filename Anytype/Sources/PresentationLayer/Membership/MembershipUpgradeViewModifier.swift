import SwiftUI


@MainActor
final class MembershipUpgradeViewModifierModel: ObservableObject {
    @Published var openUrl: URL?
    @Published var showMembershipScreen = false
    @Published var showMembershipEmailAlert = false
    
    @Injected(\.mailUrlBuilder) private var mailUrlBuilder
    @Injected(\.membershipStatusStorage) private var statusStorage
    @Injected(\.accountManager) private var accountManager
    
    nonisolated init() { }
    
    func updateState(reason: MembershipUpgradeReason?) {
        guard let reason else { return }
        guard let currentTier = statusStorage.currentStatus.tier else { return }
        
        if accountManager.account.allowMembership && currentTier.isPossibleToUpgrade(reason: reason) {
            showMembershipScreen = true
        } else {
            showMembershipEmailAlert = true
        }
    }
    
    func onTapContactAnytype() {
        openUrl = mailUrlBuilder.membershipUpgrateUrl()
        showMembershipEmailAlert = false
    }
}

struct MembershipUpgradeViewModifier: ViewModifier {
    
    @StateObject private var model = MembershipUpgradeViewModifierModel()
    @Binding private var reason: MembershipUpgradeReason?
    
    init(reason: Binding<MembershipUpgradeReason?>) {
        _reason = reason
    }
    
    func body(content: Content) -> some View {
        content
            .openUrl(url: $model.openUrl)
            .sheet(isPresented: $model.showMembershipScreen, onDismiss: {
                reason = nil
            }, content: {
                MembershipCoordinator()
            })
            .anytypeSheet(isPresented: $model.showMembershipEmailAlert, onDismiss: {
                reason = nil
            } ,content: {
                MembershipUpgradeEmailBottomAlert {
                    model.onTapContactAnytype()
                    reason = nil
                }
            })
        
            .onAppear {
                model.updateState(reason: reason)
            }
            .onChange(of: reason) { _, reason in
                model.updateState(reason: reason)
            }
    }
}


extension View {
    func membershipUpgrade(reason: Binding<MembershipUpgradeReason?>) -> some View {
        modifier(MembershipUpgradeViewModifier(reason: reason))
    }
}
