import Foundation
import SwiftUI

struct NotificationCoordinatorView: View {

    @StateObject private var model = NotificationCoordinatorViewModel()
    @Environment(\.dismissAllPresented) private var dismissAllPresented

    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .overlay(alignment: .top) {
                if model.uploadingFilesCount > 0 {
                    UploadStatusBannerView(count: model.uploadingFilesCount)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .allowsHitTesting(true)
                }
            }
            .animation(.spring(), value: model.uploadingFilesCount)
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
            .anytypeSheet(item: $model.spaceRequestAlert) {
                SpaceRequestAlert(data: $0) { reason in
                    model.onMembershipUpgrateTap(reason: reason)
                }
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
}
