import Foundation
import SwiftUI

struct GalleryUnavailableView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.Gallery.Unavailable.title,
            message: Loc.Gallery.Unavailable.message,
            icon: .BottomAlert.error,
            style: .red
        ) {
            BottomAlertButton(text: Loc.close, style: .secondary) {
                dismiss()
            }
        }
    }
}
