import SwiftUI

struct DotView: View {
    var delay: Double = 0
    @State private var filled = false
    
    var body: some View {
        Circle()
            .stroke(Color.Auth.dotSelected, lineWidth: 1)
            .background(Circle().fill(filled ? Color.Auth.dotSelected : Color.clear))
            .frame(width: 5, height: 5)
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
