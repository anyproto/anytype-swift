import SwiftUI

// Refactoring with SwiftUIObjectIconImageView
struct SwiftUIObjectIconImageViewWithPlaceholder: View {
    
    @Environment(\.redactionReasons) var redactionReasons
    
    let icon: ObjectIconImage?
    
    var body: some View {
        if redactionReasons.contains(.placeholder) {
            // Empty image for native placeholder
            Image(uiImage: UIImage())
                .resizable()
        } else if let icon {
            IconView(icon: icon)
        }
    }
}
