import SwiftUI

struct ImageUrlIconView: View {
    
    let url: URL
    
    var body: some View {
        CachedAsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            LoadingPlaceholderIconView()
        }
    }
}
