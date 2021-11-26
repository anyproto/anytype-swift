import SwiftUI

struct SetHeader: View {
    @Binding var yOffset: CGFloat
    @Binding var headerSize: CGRect
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var headerPosition = CGPoint.zero
    @State private var coverPosition = CGPoint.zero
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                SetFullHeader(
                    screenWidth: screen.size.width,
                    yOffset: yOffset,
                    headerSize: $headerSize,
                    headerPosition: $headerPosition,
                    coverPosition: $coverPosition
                )
                SetMinimizedHeader(headerPosition: headerPosition, coverPosition: coverPosition)
                    .frame(width: screen.size.width)
            }
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
