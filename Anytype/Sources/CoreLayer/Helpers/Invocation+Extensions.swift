import Foundation
import ProtobufMessages
import AnytypeCore

extension Invocation {
    func invoke(errorDomain: ErrorDomain, file: StaticString = #file, function: String = #function, line: UInt = #line) async throws -> Response {
        do {
            return try await invoke()
        } catch {
            anytypeAssertionFailure(error.localizedDescription, domain: errorDomain, file: file, function: function, line: line)
            throw error
        }
    }
}
