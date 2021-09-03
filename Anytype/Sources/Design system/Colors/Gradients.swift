import SwiftUI

final class Gradients {
    static func mainBackground() -> some View {
        return LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#74BDEC"), Color(hex: "#CFD9D9")]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
