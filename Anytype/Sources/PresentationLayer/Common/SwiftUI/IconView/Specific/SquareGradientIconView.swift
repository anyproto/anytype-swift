import SwiftUI

struct SquareGradientIconView: View {
    
    let gradientId: GradientId
    
    var body: some View {
        SquareView { side in
            GradientIconView(gradientId: gradientId)
                .mask(Circle())
                .padding(side * (1/6))
                .background(Color.Additional.space)
                .cornerRadius(side * (1/12), style: .continuous)
        }
    }
}
