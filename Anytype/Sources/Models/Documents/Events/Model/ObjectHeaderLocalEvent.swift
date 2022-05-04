import Foundation
import UIKit

enum ObjectHeaderUpdate: Hashable {
    case iconUploading(String)
    case coverUploading(ObjectCoverUpdate)
}

enum ObjectCoverUpdate: Hashable {
    case bundleImagePath(String)
    case remotePreviewURL(URL)
}
