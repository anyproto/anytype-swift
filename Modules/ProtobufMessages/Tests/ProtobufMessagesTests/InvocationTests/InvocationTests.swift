import Testing
import SwiftProtobuf
import os
@testable import ProtobufMessages

struct InvocationTests {

    @Test func testForLockInvoke() async throws {
        let invocation = Invocation(messageName: "test", request: TestRequest()) { request -> TestResponse in
            while true {}
            return TestResponse()
        }
        
        let taskIsExit = OSAllocatedUnfairLock(initialState: false)
        let task = Task {
            do {
                try await invocation.invoke()
            } catch {
                taskIsExit.withLock { $0 = true }
            }
        }
        
        // Wait task start
        try await Task.sleep(nanoseconds: 1_000_000_000 * 1)
        
        task.cancel()
        
        // Waiting to be canceled
        try await Task.sleep(nanoseconds: 1_000_000_000 * 1)
        
        let result = taskIsExit.withLock { $0 }
        #expect(result == true)
    }
}
