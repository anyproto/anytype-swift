import SwiftUI

struct DotView: View {
    
    var filled = false
    
    var body: some View {
        Circle()
            .strokeBorder(.foreground, lineWidth: 1)
            .background {
                if filled {
                    Circle().fill(.foreground)
                }
            }
    }
}

struct DotView_Previews: PreviewProvider {
    static var previews: some View {
        DotView()
    }
}
