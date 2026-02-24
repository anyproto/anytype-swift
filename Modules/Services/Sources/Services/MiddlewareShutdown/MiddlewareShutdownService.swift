import Foundation
import ProtobufMessages
import AnytypeCore

public protocol MiddlewareShutdownServiceProtocol: Sendable {
    func shutdown()
}

final class MiddlewareShutdownService: MiddlewareShutdownServiceProtocol, Sendable {

    func shutdown() {
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            defer { semaphore.signal() }
            do {
                _ = try await ClientCommands.appShutdown().invoke()
            } catch {
                anytypeAssertionFailure("Middleware shutdown failed", info: ["error": "\(error)"])
            }
        }

        _ = semaphore.wait(timeout: .now() + 3.0)
    }
}
