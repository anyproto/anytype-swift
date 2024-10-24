import Foundation
import SwiftUI

struct NotificationCoordinatorView: View {
    
    @StateObject private var model: NotificationCoordinatorViewModel
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    init(sceneId: String) {
        self._model = StateObject(wrappedValue: NotificationCoordinatorViewModel(sceneId: sceneId))
    }
    
    var body: some View {
        Color.Background.primary
            .onAppear {
                model.onAppear()
                model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
            }
            .onDisappear {
                model.onDisappear()
            }
            .anytypeSheet(item: $model.spaceRequestAlert) {
                SpaceRequestAlert(data: $0) { reason in
                    model.onMembershipUpgrateTap(reason: reason)
                }
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
}
