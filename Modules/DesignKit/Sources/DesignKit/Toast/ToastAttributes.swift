import UIKit

public struct ToastAttributes {
    public static var defaultAttributes: [NSAttributedString.Key : Any] {
        [.foregroundColor: UIColor.Text.white, .font: AnytypeFont.caption1Regular.uiKitFont]
    }
}
