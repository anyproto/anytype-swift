import Foundation
import ProtobufMessages
import AnytypeCore

extension Invocation {
    
    @discardableResult
    func invoke(errorDomain: ErrorDomain, file: StaticString = #file, function: String = #function, line: UInt = #line) async throws -> Response {
        do {
            return try await invoke()
        } catch {
            anytypeAssertionFailure(error.localizedDescription, domain: errorDomain, file: file, function: function, line: line)
            throw error
        }
    }
    
    // try? and discardableResult doesn't work.
    // We should to write `_ = try? ClientCommand...`
    // https://github.com/apple/swift/issues/45672
    @discardableResult
    func invoke(errorDomain: ErrorDomain, file: StaticString = #file, function: String = #function, line: UInt = #line) throws -> Response {
        do {
            return try invoke()
        } catch {
            anytypeAssertionFailure(error.localizedDescription, domain: errorDomain, file: file, function: function, line: line)
            throw error
        }
    }
}
