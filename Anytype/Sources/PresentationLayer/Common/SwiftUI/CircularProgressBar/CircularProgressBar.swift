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
                    Color.System.amber50,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
        .frame(idealWidth: 88, idealHeight: 88)
    }
}
