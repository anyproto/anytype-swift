import Foundation
import ProtobufMessages
import AnytypeCore

public extension Invocation {
    
    @discardableResult
    func invoke(file: StaticString = #file, function: String = #function, line: UInt = #line) async throws -> Response {
        do {
            return try await invoke(file: file)
        } catch let error as CancellationError {
            // Ignore try Task.checkCancellation()
            throw error
        } catch {
            anytypeAssertionFailure(error.localizedDescription, file: file, function: function, line: line)
            throw error
        }
    }
    
    // try? and discardableResult doesn't work.
    // We should to write `_ = try? ClientCommand...`
    // https://github.com/apple/swift/issues/45672
    @discardableResult
    func invoke(file: StaticString = #file, function: String = #function, line: UInt = #line) throws -> Response {
        do {
            return try invoke(file: file)
        } catch let error as CancellationError {
            // Ignore try Task.checkCancellation()
            throw error
        } catch {
            anytypeAssertionFailure(error.localizedDescription, file: file, function: function, line: line)
            throw error
        }
    }
}
