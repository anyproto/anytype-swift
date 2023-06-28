import SwiftUI

struct SquareImageIdView: View {
    
    let imageId: String
 
    var body: some View {
        ImageIdView(imageId: imageId)
            .mask(Rectangle().cornerRadius(2, style: .continuous))
    }
}
