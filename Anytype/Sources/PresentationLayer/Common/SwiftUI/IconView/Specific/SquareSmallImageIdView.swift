import SwiftUI

struct SquareSmallImageIdView: View {
    
    let imageId: String
 
    var body: some View {
        SmallImageIdView(imageId: imageId)
            .mask(Rectangle().cornerRadius(2, style: .continuous))
    }
}
