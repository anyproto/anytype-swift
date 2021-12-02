import SwiftUI

struct SetHeader: View {
    @Binding var headerSize: CGSize
    var offset: CGPoint
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var headerPosition = CGPoint.zero
    @State private var coverPosition = CGPoint.zero
    
    var body: some View {
        SingleAxisGeometryReader { width in
            ZStack {
                SetFullHeader(
                    screenWidth: width,
                    yOffset: offset.y,
                    headerSize: $headerSize,
                    headerPosition: $headerPosition,
                    coverPosition: $coverPosition
                )
                SetMinimizedHeader(
                    headerPosition: headerPosition,
                    coverPosition: coverPosition,
                    xOffset: offset.x
                )
                .frame(width: width)
            }
        }
    }
}

struct SetHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetHeader(headerSize: .constant(.zero), offset: .zero)
    }
}
