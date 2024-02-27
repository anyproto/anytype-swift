import XCTest

extension XCTestCase {
        
    func eventually(timeout: TimeInterval = 0.01) {
        let expectation = self.expectation(description: "")
        expectation.fulfillAfter(timeout)
        wait(for: [expectation], timeout: 10)
    }
}

extension XCTestExpectation {
    
    /// Call `fulfill()` after some time.
    ///
    /// - Parameter time: amout of time after which `fulfill()` will be called.
    func fulfillAfter(_ time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.fulfill()
        }
    }
}
