extension MembershipExternalPaymentMethod {
    var noticeText: String {
        switch self {
        case .desktop:
            Loc.Membership.ManageTier.desktop
        case .googlePlay:
            Loc.Membership.ManageTier.android
        case .appStore:
            Loc.Membership.ManageTier.appleId
        }
    }
}
