import SwiftUI

public struct CircleLoadingView: View {
    
    private enum Constants {
        static let idealSize: CGFloat = 18
        static let widthForIdealSize: CGFloat = 2
        static let paddingForIdealSize: CGFloat = 2
    }
    
    @State private var isRotating = false
    
    public init() {}
    
    public var body: some View {
        GeometryReader { reader in
            let minSide = min(reader.size.width, reader.size.height)
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.Control.active.opacity(0),
                            Color.Control.active
                        ]),
                        center: .center
                    ),
                    lineWidth: (minSide / Constants.idealSize) * Constants.widthForIdealSize
                )
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .task {
                    withAnimation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false)
                    ) {
                        isRotating = true
                    }
                }
                .padding((minSide / Constants.idealSize) * Constants.paddingForIdealSize)
        }
        .frame(idealWidth: Constants.idealSize, idealHeight: Constants.idealSize)
    }
}


#Preview {
    VStack {
        CircleLoadingView()
            .frame(width: 30, height: 30)
            .background(Color.Shape.transperentPrimary)
        
        CircleLoadingView()
            .frame(width: 50, height: 50)
            .background(Color.Shape.transperentPrimary)
        
        CircleLoadingView()
            .frame(width: 100, height: 100)
            .background(Color.Shape.transperentPrimary)
    }
}
