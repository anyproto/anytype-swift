import SwiftUI

final class Gradients {
    static func mainBackground() -> some View {
        create(topHexColor: "#74BDEC", bottomHexColor: "#CFD9D9")
    }
    
    static func create(topHexColor: String, bottomHexColor: String) -> some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: topHexColor), Color(hex: bottomHexColor)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
