import Testing
import SwiftProtobuf
@testable import ProtobufMessages

struct InvocationTests {

    @Test func testForLockInvoke() async throws {
        let invocation = Invocation(messageName: "test", request: TestRequest()) { request -> TestResponse in
            while true {}
            return TestResponse()
        }
        
        var taskIsExit = false
        let task = Task {
            do {
                try await invocation.invoke()
            } catch {
                taskIsExit = true
            }
        }
        
        // Wait task start
        try await Task.sleep(nanoseconds: 1_000_000_000 * 1)
        
        task.cancel()
        
        // Waiting to be canceled
        try await Task.sleep(nanoseconds: 1_000_000_000 * 1)
        
        #expect(taskIsExit == true)
    }
}
