import Foundation
import SwiftUI

struct UserWarningAlertCoordinatorView: View {
    
    let alert: UserWarningAlert
    
    var body: some View {
        switch alert {
        case .reindexing:
            ReindexingAlertView()
        }
    }
}
