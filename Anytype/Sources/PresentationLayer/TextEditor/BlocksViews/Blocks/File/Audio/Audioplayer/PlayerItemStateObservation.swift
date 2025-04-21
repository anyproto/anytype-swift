import AVKit

final class PlayerItemStateObservation: NSObject {
    
    private var currentItem: AVPlayerItem?
    private var playerItemContext = 0
    
    var onReadyToPlay: (() -> Void)?
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            if status == .readyToPlay {
                onReadyToPlay?()
            }
        }
    }
    
    func observe(item: AVPlayerItem?) {
        currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        currentItem = item
        // Item status observer
        currentItem?.addObserver(self,
                                 forKeyPath: #keyPath(AVPlayerItem.status),
                                 options: .new,
                                 context: &playerItemContext)
    }
    
    deinit {
        currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
}
