import Foundation
import SwiftUI

struct UserWarningAlertCoordinatorView: View {
    
    let data: UserWarningAlertData
    
    var body: some View {
        switch data.alert {
        case .reindexing:
            ReindexingAlertView(onDismiss: data.onDismiss)
        }
    }
}
