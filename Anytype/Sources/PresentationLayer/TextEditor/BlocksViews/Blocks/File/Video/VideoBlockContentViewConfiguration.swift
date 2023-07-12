import Services
import UIKit

struct VideoBlockConfiguration: BlockConfiguration {
    typealias View = VideoBlockContentView
    
    let file: BlockFile
    
    @EquatableNoop private(set) var action: (VideoControlStatus?) -> Void
}

enum VideoControlStatus {
    case playing
    case paused
}
