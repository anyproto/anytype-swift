import SwiftUI

struct ProgressBarWithAnimation: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { geo in
                Capsule()
                    .foregroundColor(.strokePrimary)
                Capsule()
                    .foregroundColor(.textPrimary)
                    .offset(x: isAnimating ? geo.size.width : -geo.size.width)
                    .clipShape(Capsule())
            }
        }
        .frame(height: 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

struct ProgressBarWithAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarWithAnimation().padding()
    }
}
