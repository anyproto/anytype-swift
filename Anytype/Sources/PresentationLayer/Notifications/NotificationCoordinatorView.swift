import Foundation
import SwiftUI

struct NotificationCoordinatorView: View {

    @StateObject private var model = NotificationCoordinatorViewModel()
    @Environment(\.dismissAllPresented) private var dismissAllPresented

    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .overlay(alignment: .top) {
                if let text = model.uploadStatusText {
                    UploadStatusBannerView(text: text)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .allowsHitTesting(true)
                }
            }
            .animation(.spring(), value: model.uploadStatusText)
            .onAppear {
                model.onAppear()
                model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
            }
            .onDisappear {
                model.onDisappear()
            }
            .taskWithMemoryScope {
                await model.startHandleSyncStatus()
            }
            .taskWithMemoryScope {
                await model.startHandleSpaceLoading()
            }
            .anytypeSheet(item: $model.spaceRequestAlert) {
                SpaceRequestAlert(data: $0) { reason in
                    model.onMembershipUpgrateTap(reason: reason)
                }
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
}
