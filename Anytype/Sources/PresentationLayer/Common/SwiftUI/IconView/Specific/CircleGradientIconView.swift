import SwiftUI

struct CircleGradientIconView: View {
    
    let gradientId: GradientId
    
    var body: some View {
        GradientIconView(gradientId: gradientId)
            .mask(Circle())
    }
}
