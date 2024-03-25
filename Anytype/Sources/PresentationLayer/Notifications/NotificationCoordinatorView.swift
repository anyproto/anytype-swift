import Foundation
import SwiftUI

struct NotificationCoordinatorView: View {
    
    @StateObject private var model = NotificationCoordinatorViewModel()
    
    var body: some View {
        Color.Background.primary
            .onAppear {
                model.onAppear()
            }
            .onDisappear {
                model.onDisappear()
            }
    }
}
