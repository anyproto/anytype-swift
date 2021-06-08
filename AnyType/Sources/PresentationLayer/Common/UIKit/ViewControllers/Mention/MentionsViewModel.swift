
import Combine
import UIKit

final class MentionsViewModel {
    
    private let service: MentionObjectsService
    private weak var view: MentionsView?
    private var subscription: AnyCancellable?
    private var imageLoadingSubscriptions = [AnyCancellable]()
    private var imageStorage = [String: ImageProperty]()
    
    init(service: MentionObjectsService) {
        self.service = service
    }
    
    func setFilterString(_ string: String) {
        service.setFilterString(string)
        imageLoadingSubscriptions.removeAll()
        obtainMentions()
    }
    
    func setup(with view: MentionsView) {
        self.view = view
        obtainMentions()
    }
    
    func didSelectMention(_ mention: MentionObject) {
        
    }
    
    func createNewMention() {
        
    }
    
    func image(for mention: MentionObject) -> UIImage? {
        if let imageProperty = imageStorage[mention.id] {
            return imageProperty.property
        }
        if case let .imageId(id) = mention.iconData {
            let property = ImageProperty(imageId: id, ImageParameters(width: .thumbnail))
            let loadImage = property.stream.sink { [weak self] image in
                guard image != nil else { return }
                self?.view?.update(mention: .mention(mention))
            }
            imageLoadingSubscriptions.append(loadImage)
            imageStorage[mention.id] = property
        }
        return nil
    }
    
    private func obtainMentions() {
        subscription = service.obtainMentionsPublisher().sink(receiveCompletion: { result in
            switch result {
            case let .failure(error):
                assertionFailure(error.localizedDescription)
            case .finished:
                break
            }
        }) { [weak self] mentions in
            self?.view?.display(mentions.map { .mention($0) })
        }
    }
}
