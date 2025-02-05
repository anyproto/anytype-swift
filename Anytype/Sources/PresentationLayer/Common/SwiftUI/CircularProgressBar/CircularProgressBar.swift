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
                            UIColor.System.amber50.light.suColor,
                            UIColor.System.amber100.light.suColor
                        ],
                        center: .center
                    ),
                    lineWidth: 8
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
        .frame(idealWidth: 88, idealHeight: 88)
    }
}
