
public enum AppTargetType: Sendable {
    case debug
    case releaseAnytype
    case releaseAnyApp
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
    
    var isReleaseAnyApp: Bool {
        if case .releaseAnyApp = self { return true }
        return false
    }
}
