import SwiftUI

struct CircleLoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color.Control.active.opacity(0),
                        Color.Control.active
                    ]),
                    center: .center
                ),
                lineWidth: 4
            )
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .frame(idealWidth: 32, idealHeight: 32)
            .task {
                withAnimation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    isRotating = true
                }
            }
    }
}
