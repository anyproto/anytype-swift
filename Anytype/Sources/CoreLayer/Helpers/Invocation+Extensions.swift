import Foundation
import ProtobufMessages
import AnytypeCore

extension Invocation {
    func invoke(errorDomain: ErrorDomain, file: StaticString = #file, line: UInt = #line) async throws -> Response {
        do {
            return try await invoke()
        } catch {
            anytypeAssertionFailure(error.localizedDescription, domain: errorDomain, file: file, line: line)
            throw error
        }
    }
}
