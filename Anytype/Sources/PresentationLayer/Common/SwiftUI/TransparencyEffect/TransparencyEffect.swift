import SwiftUI

struct TransparencyEffect: View {
    
    let edge: Edge
    let length: CGFloat
    
    var body: some View {
        switch edge {
        case .trailing:
            trailingEffect
        case .leading:
            leadingEffect
        case .top:
            topEffect
        case .bottom:
            bottomEffect
        }
    }
    
    private var trailingEffect: some View {
        HStack(spacing: 0) {
            Spacer()
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.backgroundPrimary.opacity(0),
                        Color.backgroundPrimary
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
                .frame(width: length)
        }
    }
    
    private var leadingEffect: some View {
        HStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundPrimary.opacity(0)
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
                .frame(width: length)
            Spacer()
        }
    }
    
    private var topEffect: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundPrimary.opacity(0)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
                .frame(height: length)
            Spacer()
        }
    }
    
    private var bottomEffect: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.backgroundPrimary.opacity(0),
                        Color.backgroundPrimary
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
                .frame(height: length)
        }
    }
}

extension TransparencyEffect {
    
    enum Edge {
        case trailing
        case leading
        case top
        case bottom
    }
    
}

struct TransparencyEffect_Previews: PreviewProvider {
    static var previews: some View {
        Color.red.overlay(
            TransparencyEffect(edge: .bottom, length: 40)
        )
    }
}
