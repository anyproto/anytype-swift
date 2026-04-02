import SwiftUI
import DesignKit

struct SharedChannelLimitView: View {

    let sharedSpacesLimit: Int
    let onUpgrade: () -> Void
    let onManageChannels: () -> Void

    var body: some View {
        BottomAlertView(
            title: Loc.Channel.SharedLimit.title,
            message: Loc.Channel.SharedLimit.subtitle(sharedSpacesLimit)
        ) {
            BottomAlertButton(
                text: "\(MembershipConstants.membershipSymbol.rawValue) \(Loc.upgrade)",
                style: .primary
            ) {
                onUpgrade()
            }
            BottomAlertButton(
                text: Loc.Channel.SharedLimit.manageChannels,
                style: .secondary
            ) {
                onManageChannels()
            }
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenHitShareSpaceLimit()
        }
    }
}
