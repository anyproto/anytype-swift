import Combine
import UIKit
import BlocksModels

final class DocumentIconViewModel {
    
    var onMediaPickerImageSelect: ((UIImage) -> Void)?

    let icon: DocumentIcon
    
    private var notificationSubscription: AnyCancellable?
        
    // MARK: - Initializer
    
    init(icon: DocumentIcon) {
        self.icon = icon
        
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
