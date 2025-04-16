import UIKit

protocol CustomTypesAccessable: AnyObject {
    @MainActor
    var isMoving: Bool { get set }
    @MainActor
    var isLocked: Bool { get set }
}

extension UIConfigurationStateCustomKey {
    static let isMoving = UIConfigurationStateCustomKey("com.anytypeio.cell.isMoving")
    static let isLocked = UIConfigurationStateCustomKey("com.anytypeio.cell.isLocked")
}

extension UICellConfigurationState {
    var isMoving: Bool {
        get { self[.isMoving] as? Bool ?? false }
        set { self[.isMoving] = newValue }
    }

    var isLocked: Bool {
        get { self[.isLocked] as? Bool ?? false }
        set { self[.isLocked] = newValue }
    }
}
