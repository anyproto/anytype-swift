import SwiftUI
import Services
import AnytypeCore


struct MembershipCodeActivationData: Identifiable {
    let id = UUID()
    let code: String?
    let route: MembershipCodeRoute
}

@MainActor
@Observable
final class MembershipCodeActivationViewModel {
    var code: String
    var errorText: String?
    var isActivating = false

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol

    @ObservationIgnored
    private let route: MembershipCodeRoute
    @ObservationIgnored
    private let onRedeemed: (MembershipTierType?) async -> Void

    init(data: MembershipCodeActivationData, onRedeemed: @escaping (MembershipTierType?) async -> Void) {
        self.code = data.code ?? ""
        self.route = data.route
        self.onRedeemed = onRedeemed
    }

    func onCodeChanged() {
        errorText = nil
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenMembershipCode(route: route)
    }

    func activate() async {
        errorText = nil
        AnytypeAnalytics.instance().logClickMembershipCode()

        isActivating = true
        defer { isActivating = false }

        let submittedCode = code
        do {
            try await membershipService.codeGetInfo(code: submittedCode)
            let redeemedTier = try await membershipService.codeRedeem(code: submittedCode)
            await onRedeemed(redeemedTier)
        } catch {
            errorText = error.localizedDescription
        }
    }
}
