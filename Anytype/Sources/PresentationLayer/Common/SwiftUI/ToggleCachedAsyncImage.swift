import DesignKit
import CachedAsyncImage
import SwiftUI
import AnytypeCore

// Delete with toggle FeatureFlags.anytypeImageCacher

extension ToggleCachedAsyncImage {
    init<I: View, P: View>(
        url: URL?,
        urlCache: URLCache,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, urlCache: urlCache) { state in
            if let image = state.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

struct ToggleCachedAsyncImage<Content: View>: View {
    
    private let url: URL?
    private let urlCache: URLCache
    private let content: (AsyncImagePhase) -> Content
    @State private var state: AsyncImagePhase = .empty
    
    public init(url: URL?, urlCache: URLCache, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.urlCache = urlCache
        self.content = content
    }
    
    public var body: some View {
        if FeatureFlags.anytypeImageCacher {
            DesignKit.CachedAsyncImage(
                url: url,
                content: content
            )
        } else {
            CachedAsyncImage(
                url: url,
                urlCache: .anytypeImages,
                content: content
            )
        }
    }
}
