
public enum AppTargetType: Sendable {
    case debug
    case releaseAnytype
}

public extension AppTargetType {
    var isDebug: Bool {
        if case .debug = self { return true }
        return false
    }
    
    var isReleaseAnytype: Bool {
        if case .releaseAnytype = self { return true }
        return false
    }
}
