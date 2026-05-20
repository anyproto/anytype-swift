import SwiftUI

@MainActor
final class MembershipUpgradeViewModifierModel: ObservableObject {
    @Published var showMembershipScreen = false

    @Injected(\.accountManager) private var accountManager

    nonisolated init() { }

    func updateState(reason: MembershipUpgradeReason?) {
        guard reason != nil else { return }
        guard accountManager.account.allowMembership else { return }
        showMembershipScreen = true
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
            .sheet(isPresented: $model.showMembershipScreen, onDismiss: {
                reason = nil
            }, content: {
                MembershipCoordinator()
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
