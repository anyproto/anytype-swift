import SwiftUI

struct CircularProgressBar: View {

    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.Shape.secondary,
                    lineWidth: 8
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.System.amber100,
                            Color.System.amber50
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(350)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
        .frame(idealWidth: 88, idealHeight: 88)
    }
}
