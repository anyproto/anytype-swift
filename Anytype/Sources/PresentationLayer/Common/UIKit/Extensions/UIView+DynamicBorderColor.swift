import Foundation
import UIKit
import AnytypeCore

extension UIView {
    
    private static var borderColorsStore = NSMapTable<UIView, UIColor>.weakToStrongObjects()
    
    var dynamicBorderColor: UIColor? {
        get {
            return UIView.borderColorsStore.object(forKey: self)
        }
        set {
            UIView.borderColorsStore.setObject(newValue, forKey: self)
            updateNotificationSubscription()
            updateBorderColor()
        }
    }

    private func updateNotificationSubscription() {
        if dynamicBorderColor == nil {
            NotificationCenter.default.removeObserver(
                self,
                name: .traitCollectionDidChangeNotification,
                object: nil
            )
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(traitCollectionDidChangeNotification),
                name: .traitCollectionDidChangeNotification,
                object: nil
            )
        }
    }
    
    @objc func traitCollectionDidChangeNotification() {
         updateBorderColor()
    }
    
    private func updateBorderColor() {
        layer.borderColor = dynamicBorderColor?.cgColor
    }
}
