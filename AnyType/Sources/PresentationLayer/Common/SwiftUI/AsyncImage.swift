import SwiftUI

struct AsyncImage: View {
    @StateObject private var loader: SwiftUIImageLoader

    init(imageId: String, parameters: ImageParameters) {
        _loader = StateObject(
            wrappedValue: SwiftUIImageLoader(imageId: imageId, parameters: parameters)
        )
    }

    var body: some View {
        Image(uiImage: loader.image ?? UIImage())
            .resizable()
            .redacted(reason: loader.image == nil ? .placeholder : [])
            
            .onAppear(perform: loader.load)
    }
}
