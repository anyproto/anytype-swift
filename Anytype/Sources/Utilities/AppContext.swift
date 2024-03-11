import Foundation

enum AppContext {
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
