import UIKit.UIImageView

extension UIImageView {
        
    func addDimmedOverlay(with color: UIColor = UIColor(white: 0.0, alpha: 0.32)) {
        let dimmedOverlayView = UIView()
        dimmedOverlayView.backgroundColor = color
        
        addSubview(dimmedOverlayView)
        dimmedOverlayView.layoutUsing.anchors {
            $0.pinToSuperview()
        }
    }
    
}

extension UIImageView {
    
    var wrapper: AnytypeImageViewWrapper {
        AnytypeImageViewWrapper(imageView: self)
    }
    
}
