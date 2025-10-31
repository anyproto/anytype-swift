import SwiftUI
import ConfettiSwiftUI


struct ConfettiOverlay: View {
    @Binding var fireConfetti: Bool
    @State private var counter: Int = 0
    
    private var confettiHeight: CGFloat {
        UIScreen.main.bounds.height - 100
    }
    
    var body: some View {
        EmptyView()
            .confettiCannon(counter: $counter, num: 200, rainHeight: confettiHeight, radius: confettiHeight)
            .onAppear { updateState() }
            .onChange(of: fireConfetti) { updateState() }
    }
    
    private func updateState() {
        if fireConfetti {
            counter += 1
            Task {
                try await Task.sleep(seconds: 1)
                self.fireConfetti = false
            }
        }
    }
}

#Preview {
    ConfettiOverlay(fireConfetti: .constant(false))
}
