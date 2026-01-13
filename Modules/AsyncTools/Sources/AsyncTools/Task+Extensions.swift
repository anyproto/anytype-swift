import Foundation

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(for: .seconds(seconds))
    }
}
