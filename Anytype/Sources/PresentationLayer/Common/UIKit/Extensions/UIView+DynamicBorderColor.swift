import Foundation
import UIKit
import AnytypeCore

extension UIView {
    
    private static var borderColorsStore = NSMapTable<UIView, UIColor>.weakToStrongObjects()
    
    var dynamicBorderColor: UIColor? {
        get {
            if FeatureFlags.fixColorsForStyleMenu {
                return UIView.borderColorsStore.object(forKey: self)
            } else {
                return layer.borderColor.map { UIColor(cgColor: $0) }
            }
        }
        set {
            if FeatureFlags.fixColorsForStyleMenu {
                UIView.borderColorsStore.setObject(newValue, forKey: self)
                updateNotificationSubscription()
                updateBorderColor()
            } else {
                layer.borderColor = newValue?.cgColor
            }
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
