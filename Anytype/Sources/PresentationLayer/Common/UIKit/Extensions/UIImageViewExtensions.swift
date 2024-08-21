import UIKit.UIImageView

extension UIImageView {
    
    var wrapper: any DownloadableImageViewWrapperProtocol {
        DownloadableImageViewWrapper(imageView: self)
    }
    
}
