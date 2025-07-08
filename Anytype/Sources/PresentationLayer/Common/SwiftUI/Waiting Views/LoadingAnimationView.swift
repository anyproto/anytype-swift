import SwiftUI

struct LoadingAnimationView: View {
    @Binding var showError: Bool
    @State private var shouldAnimate = false
    private let circleSize: CGFloat = 12
    
    var color: Color {
        if showError {
            return Color.Pure.red
        }
        
        return shouldAnimate ? Color.Shape.primary : Color.Shape.tertiary
    }
    
    var scale: CGFloat {
        if showError {
            return 1
        }
        
        return shouldAnimate ? 1 : 0.5
    }
    
    var body: some View {
        HStack(alignment: .center) {
            circle(animationDelay: 0)
            circle(animationDelay: 0.3)
            circle(animationDelay: 0.6)
        }
        .onAppear {
            // Hack to fix broken animation, do not remove
            // Without this line animation bounces vertically
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                shouldAnimate = true
            }
        }
    }
    
    private func circle(animationDelay: Double) -> some View {
        Circle()
            .fill(color)
            .frame(width: circleSize, height: circleSize)
            .scaleEffect(scale)
            .if(!showError) { circle in
                circle.animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever().delay(animationDelay),
                    value: shouldAnimate
                )
            }
    }
}

struct LoadingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimationView(showError: .constant(false))
    }
}
