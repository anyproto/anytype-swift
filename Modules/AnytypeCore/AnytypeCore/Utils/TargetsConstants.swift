public struct TargetsConstants {    
    public static var appGroup: String  {
        switch CoreEnvironment.targetType {
        case .debug:
            return "group.io.anytype.app.dev"
        case .releaseAnytype:
            return "group.io.anytype.app"
        case .releaseAnyApp:
            return "group.org.any.app"
        }
    }
}
