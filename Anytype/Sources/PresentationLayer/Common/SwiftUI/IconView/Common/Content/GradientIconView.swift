import SwiftUI

struct GradientIconView: View {
    
    let gradientId: GradientId
    private let gradient: IconGradient
    
    init(gradientId: GradientId) {
        self.gradientId = gradientId
        // TODO: Change to static config
        self.gradient = IconGradientStorage.gradient(for: gradientId.rawValue)
    }
    
    var body: some View {
        SquareView { side in
            RadialGradient(
                stops: [
                    .init(color: gradient.centerColor.suColor, location: gradient.centerLocation),
                    .init(color: gradient.roundColor.suColor, location: gradient.roundLocation),
                ],
                center: .center,
                startRadius: 0,
                endRadius: side
            )
        }
    }
}

struct GradientIconView_Previews: PreviewProvider {
    static var previews: some View {
        GradientIconView(gradientId: GradientId(1)!)
    }
}
