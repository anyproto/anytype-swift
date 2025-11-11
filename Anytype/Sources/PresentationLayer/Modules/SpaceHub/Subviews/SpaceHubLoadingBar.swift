import SwiftUI

struct SpaceHubLoadingBar: View {
    var showAnimation: Bool

    var body: some View {
        Group {
            if showAnimation {
                SpaceHubLoadingBarAnimated()
            } else {
                SpaceHubLoadingBarStub()
            }
        }
    }
}

struct SpaceHubLoadingBarAnimated: View {
    @State private var isAnimating = false
    private let timing: Double = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.Control.accent25)
                    .frame(height: 3)

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.Control.accent25,
                        Color.Control.accent100,
                        Color.Control.accent25
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width, height: 3)
                .offset(x: isAnimating ? 150 : -150)
            }
            .frame(height: 3)
            .clipped()
        }
        .frame(height: 3)
        .onAppear {
            withAnimation(Animation.spring(duration: timing).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

struct SpaceHubLoadingBarStub: View {
    var body: some View {
        Color.clear
            .frame(height: 3)
    }
}

#Preview {
    SpaceHubLoadingBar(showAnimation: true)
}
