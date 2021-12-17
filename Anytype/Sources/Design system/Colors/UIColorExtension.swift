import UIKit
import AnytypeCore

extension UIColor: AnytypeColorProtocol {
    @available(*, deprecated, message: "Please use colors from pallete")
    static var highlighterColor: UIColor {
        .init(red: 255.0/255.0, green: 181.0/255.0, blue: 34.0/255.0, alpha: 1)
    }

    @available(*, deprecated, message: "Please use colors from pallete")
    static let buttonActive = UIColor.grayscale50
}
