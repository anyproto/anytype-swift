import SwiftUI
import Combine

class SwiftUIImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let imageId: String
    private let parameters: ImageParameters
    private var imageSubscription: AnyCancellable?

    init(imageId: String, parameters: ImageParameters) {
        self.imageId = imageId
        self.parameters = parameters
        
        load()
    }
    
    private func load() {
        if let image = ImageCache.shared.image(imageId: imageId, parameters) {
            self.image = image
            return
        }
        
        guard let url = NewUrlResolver.resolvedUrl(.image(id: imageId, width: .thumbnail)) else { return }
        
        imageSubscription = ImageLoaderObject(url).imagePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                self?.image = image
            }
    }
}
