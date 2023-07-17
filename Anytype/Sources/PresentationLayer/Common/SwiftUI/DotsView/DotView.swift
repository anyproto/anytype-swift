import SwiftUI

struct DotView: View {
    var delay: Double = 0
    @State private var filled = false
    
    var body: some View {
        Circle()
            .stroke(.foreground, lineWidth: 1)
            .background {
                if filled {
                    Circle().fill(.foreground)
                }
            }
            .animation(Animation.linear(duration: 0.5).repeatForever().delay(delay), value: UUID())
            .task {
                try? await Task.sleep(seconds: 0.1)
                filled.toggle()
            }
    }
}

struct DotView_Previews: PreviewProvider {
    static var previews: some View {
        DotView()
    }
}
