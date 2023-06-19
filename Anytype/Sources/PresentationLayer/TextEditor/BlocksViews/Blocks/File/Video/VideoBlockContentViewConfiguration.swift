import Services
import UIKit

struct VideoBlockConfiguration: BlockConfiguration {
    typealias View = VideoBlockContentView
    
    let file: BlockFile
}
