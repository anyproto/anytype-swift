import Foundation

struct MembershipDeepLinkData: Identifiable {
    let id = UUID()
    let tierId: Int?
    let code: String?
}
