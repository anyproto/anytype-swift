import SwiftUI

struct SquareView<T: View>: View {
    
    let content: (_ size: CGFloat) -> T
    
    init(@ViewBuilder content: @escaping (_ side: CGFloat) -> T) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { reader in
            let minSide = min(reader.size.width, reader.size.height)
            content(minSide)
                .frame(width: minSide, height: minSide)
        }
    }
}
