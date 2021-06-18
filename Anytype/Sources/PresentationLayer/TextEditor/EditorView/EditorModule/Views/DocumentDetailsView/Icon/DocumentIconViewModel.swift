import Combine
import UIKit
import BlocksModels

final class DocumentIconViewModel {
    
    var onMediaPickerImageSelect: ((UIImage) -> Void)?

    let documentIcon: DocumentIcon
    
    private var notificationSubscription: AnyCancellable?
        
    // MARK: - Initializer
    
    init(documentIcon: DocumentIcon) {
        self.documentIcon = documentIcon
        
        notificationSubscription = NotificationCenter.Publisher(
            center: .default,
            name: .documentIconImageUploadingEvent,
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
