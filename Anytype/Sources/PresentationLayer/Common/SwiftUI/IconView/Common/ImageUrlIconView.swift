import SwiftUI

struct ImageUrlIconView: View {
    
    let url: URL
    
    var body: some View {
        ToggleCachedAsyncImage(
            url: url,
            urlCache: .anytypeImages
        ) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            LoadingPlaceholderIconView()
        }
    }
}
