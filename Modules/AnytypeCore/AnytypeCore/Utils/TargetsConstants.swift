public enum TargetsConstants {
#if DEBUG || RELEASE_NIGHTLY
    public static let appGroup = "group.io.anytype.app.dev"
#elseif RELEASE_ANYTYPE
    public static let appGroup = "group.io.anytype.app"
#elseif RELEASE_ANYAPP
    public static let appGroup = "group.org.any.app"
#endif
}
