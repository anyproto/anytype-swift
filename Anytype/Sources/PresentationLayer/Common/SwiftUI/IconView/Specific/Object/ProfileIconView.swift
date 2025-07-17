import Foundation
import SwiftUI
import Services

struct ProfileIconView: View {
    
    let icon: ObjectIcon.Profile
    
    var body: some View {
        Group {
            switch icon {
            case .imageId(let imageId):
                ImageIdIconView(imageId: imageId)
            case .name(let name):
                ImageCharIconView(text: name.withPlaceholder)
            case .placeholder:
                LoadingPlaceholderIconView()
            }
        }
        .background(Color.Background.highlightedMedium)
        .circleOverCornerRadius()
    }
}
