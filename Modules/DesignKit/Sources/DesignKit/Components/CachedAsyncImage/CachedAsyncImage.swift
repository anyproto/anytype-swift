import SwiftUI
import Combine

public extension CachedAsyncImage {
    init<I: View, P: View>(
        url: URL?,
        cache: CachedAsyncImageCache = .default,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, cache: cache) { state in
            if let image = state.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

public struct CachedAsyncImage<Content: View>: View {
    
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    @State private var model: CachedAsyncImageModel
    
    public init(url: URL?, cache: CachedAsyncImageCache = .default, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        self._model = State(wrappedValue: CachedAsyncImageModel(url: url, cache: cache))

    }
    
    public var body: some View {
        VStack {
            content(model.state)
        }
        .task(id: url) {
            await model.update(url: url)
        }
    }
}

@MainActor
@Observable
private final class CachedAsyncImageModel {
    
    var state: AsyncImagePhase = .empty
    
    private let cache: CachedAsyncImageCache
    @ObservationIgnored
    private var currentURL: URL?
    
    init(url: URL?, cache: CachedAsyncImageCache) {
        self.cache = cache
        self.currentURL = url
        if let url, let uiImage = try? cache.cachedImage(from: url) {
            self.state = .success(Image(uiImage: uiImage))
        } else {
            self.state = .empty
        }
    }
    
    func update(url: URL?) async {
        guard url != currentURL || state.image.isNil else { return }
        
        defer { currentURL = url }
        
        guard let url else {
            state = .empty
            return
        }
        
        do {
            let uiImage = try await cache.loadImage(from: url)
            let image = Image(uiImage: uiImage)
            state = .success(image)
        } catch {
            state = .failure(error)
        }
    }
}
