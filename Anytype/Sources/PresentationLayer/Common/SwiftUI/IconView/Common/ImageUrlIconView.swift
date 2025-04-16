import SwiftUI
import CachedAsyncImage

struct ImageUrlIconView: View {
    
    let url: URL
    
    var body: some View {
        AsyncImage(
            url: url
        ) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            LoadingPlaceholderIconView()
        }
    }
}
