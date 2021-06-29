import Combine
import UIKit
import BlocksModels

final class DocumentCoverViewModel {
    
    var onMediaPickerImageSelect: ((UIImage) -> Void)?

    let cover: DocumentCover
    
    // MARK: - Private variables
    
    private var notificationSubscription: AnyCancellable?
    
    // MARK: - Initializer
    
    init(cover: DocumentCover) {
        self.cover = cover

        notificationSubscription = NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            self?.onMediaPickerImageSelect?(image)
        }
    }
    
}
