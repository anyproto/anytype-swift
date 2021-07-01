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
        
        URLResolver().obtainImageURL(imageId: imageId, parameters: parameters) { [weak self] url in
            guard let url = url else { return }
            
            self?.imageSubscription = ImageLoaderObject(url).imagePublisher
                .subscribe(on: DispatchQueue.global())
                .receive(on: RunLoop.main)
                .sink { image in
                    self?.image = image
                }
        }
    }
}
