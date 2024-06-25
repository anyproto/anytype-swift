extension MembershipExternalPaymentMethod {
    var noticeTitle: String {
        switch self {
        case .desktop:
            Loc.desktopPlatform
        case .googlePlay:
            Loc.androidPlatform
        case .appStore:
            Loc.anotherAppleIdAccount
        }
    }
}
