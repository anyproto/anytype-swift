import SwiftUI

struct CircleImageIdView: View {
    
    let imageId: String
 
    var body: some View {
        ImageIdView(imageId: imageId)
            .mask(Circle())
    }
}
