import Foundation

public extension BlockInformation {
    
    var isLocked: Bool {
        guard let isLockedField = fields[BlockFieldBundledKey.isLocked.rawValue],
              case let .boolValue(isLocked) = isLockedField.kind else {
            return false
        }

        return isLocked
    }
}
