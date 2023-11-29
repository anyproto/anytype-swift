import Foundation
import SwiftUI

struct DocumentCommonOpenErrorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let cancel: () -> Void
    
    var body: some View {
        BottomAlertView(
            title: Loc.error,
            message: Loc.unknownError
        ) {
            BottomAlertButton(text: Loc.close, style: .secondary, loading: false) {
                dismiss()
                cancel()
            }
        }
    }
}
