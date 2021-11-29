import UIKit

protocol CustomTypesAccessable: AnyObject {
    var isMoving: Bool { get set }
}

extension UIConfigurationStateCustomKey {
    static let isMoving = UIConfigurationStateCustomKey("com.anytypeio.cell.isMoving")
}

extension UICellConfigurationState {
    var isMoving: Bool {
        get { self[.isMoving] as? Bool ?? false }
        set { self[.isMoving] = newValue }
    }
}

extension BaseBlockView: CustomTypesAccessable {
    var isMoving: Bool {
        get {
            currentConfiguration.currentConfigurationState?.isMoving ?? false
        }
        set {
            currentConfiguration.currentConfigurationState?.isMoving = newValue
        }
    }
}
