import Foundation
import SwiftUI

struct NotificationCoordinatorView: View {
    
    @StateObject private var model = NotificationCoordinatorViewModel()
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    var body: some View {
        Color.Background.primary
            .onAppear {
                model.onAppear()
                model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
            }
            .onDisappear {
                model.onDisappear()
            }
            .anytypeSheet(item: $model.spaceIdForDeleteAlert) {
                SpaceDeleteAlert(spaceId: $0.value)
            }
            .anytypeShareView(item: $model.exportSpaceUrl)
    }
}
