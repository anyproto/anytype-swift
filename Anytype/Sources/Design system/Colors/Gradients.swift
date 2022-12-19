import SwiftUI

final class Gradients {
    static func mainBackground() -> some View {
        create(topHexColor: "#74BDEC", bottomHexColor: "#CFD9D9")
    }
    
    static func widgetsBackground() -> some View {
        create(topHexColor: "#D8A5DE", bottomHexColor: "#F7CC8E")
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
