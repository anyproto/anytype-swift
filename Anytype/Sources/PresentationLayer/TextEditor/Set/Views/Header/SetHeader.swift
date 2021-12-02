import SwiftUI

struct SetHeader: View {
    @Binding var offset: CGPoint
    @Binding var headerSize: CGRect
    
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
        .onAppear {
            DispatchQueue.main.async {
                offset = .zero
            }
        }
    }
}

struct SetHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetHeader(offset: .constant(.zero), headerSize: .constant(.zero))
    }
}
