import SwiftUI

struct MembershipUpgradeEmailBottomAlert: View {
    let action: () -> ()
    
    var body: some View {
        BottomAlertView(
            title: Loc.Membership.Upgrade.title,
            message: Loc.Membership.Upgrade.text
        ) {
            BottomAlertButton(
                text: Loc.Membership.Upgrade.button,
                style: .primary
            ) {
                action()
            }
        }
    }
}

#Preview {
    MembershipUpgradeEmailBottomAlert { }
}
