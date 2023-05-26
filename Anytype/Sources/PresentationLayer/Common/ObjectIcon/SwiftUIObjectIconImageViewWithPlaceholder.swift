import SwiftUI

// Refactoring with SwiftUIObjectIconImageView
struct SwiftUIObjectIconImageViewWithPlaceholder: View {
    
    @Environment(\.redactionReasons) var redactionReasons
    
    let iconImage: ObjectIconImage?
    let usecase: ObjectIconImageUsecase
    
    var body: some View {
        if redactionReasons.contains(.placeholder) {
            // Empty image for native placeholder
            Image(uiImage: UIImage())
                .resizable()
        } else if let iconImage {
            SwiftUIObjectIconImageView(iconImage: iconImage, usecase: usecase)
        }
    }
}
