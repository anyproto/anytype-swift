import Foundation
import UIKit
import Combine

final class ObjectHeaderLocalEventsListener {
    
    // MARK: - Private variables
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Internal functions
    
    func beginObservingEvents(with onReceive: @escaping (ObjectHeaderLocalEvent) -> Void) {
        NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
            .map {
                guard let string = $0.object as? String else { return nil }
                return UIImage(contentsOfFile: string)
            }
            .receiveOnMain()
            .sink {
                onReceive(.coverUploading($0))
            }
            .store(in: &subscriptions)
        
        NotificationCenter.Publisher(
            center: .default,
            name: .documentIconImageUploadingEvent,
            object: nil
        )
            .map {
                guard let string = $0.object as? String else { return nil }
                return UIImage(contentsOfFile: string)
            }
            .receiveOnMain()
            .sink { onReceive(.iconUploading($0)) }
            .store(in: &subscriptions)
    }
    
}
