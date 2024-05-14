import Foundation
import SwiftUI
import Services

struct SpaceIconView: View {
    
    let icon: ObjectIcon.Space
    
    var body: some View {
        switch icon {
        case .name(let name):
            ImageCharIconView(text: name.withPlaceholder)
                .background(Color.Shape.secondary)
                .cornerRadius(2, style: .continuous)
        case .gradient(let gradientId):
            CircleGradientView(gradientId: gradientId)
                .scaleEffect(0.75)
                .background(Color.Additional.space)
                .cornerRadius(2, style: .continuous)
        }
    }
}
