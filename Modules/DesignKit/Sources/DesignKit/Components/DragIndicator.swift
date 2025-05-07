import SwiftUI

public struct DragIndicator: View {
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer.fixedHeight(6)
            content
            Spacer.fixedHeight(6)
        }
    }
    
    private var content: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.Shape.primary)
                .frame(width: 48, height: 4)
            Spacer()
        }
    }
}

struct DragIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DragIndicator()
    }
}
