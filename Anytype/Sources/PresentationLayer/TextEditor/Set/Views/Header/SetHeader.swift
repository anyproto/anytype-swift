import SwiftUI

struct SetHeader: View {
    @Binding var yOffset: CGFloat
    @Binding var headerSize: CGRect
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var headerPosition = CGPoint.zero
    
    var body: some View {
        ZStack {
            SetFullHeader(yOffset: yOffset, headerSize: $headerSize, headerPosition: $headerPosition)
            SetMinimizedHeader(headerPosition: headerPosition)
        }
        .onAppear {
            DispatchQueue.main.async {
                yOffset = 0
            }
        }
    }
}

struct SetHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetHeader(yOffset: .constant(.zero), headerSize: .constant(.zero))
    }
}
