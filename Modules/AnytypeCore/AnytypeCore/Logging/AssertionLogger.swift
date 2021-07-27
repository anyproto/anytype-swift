public protocol Logger {
    func log(_ message: String)
}

public final class AssertionLogger {
    public static var shared: Logger?
}
