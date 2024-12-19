import Testing
@testable import Anytype

struct ChatMessageLimitsTests {
    
    let limits = ChatMessageLimits()
    
    @Test func checkLimit() async throws {
        
        sentMessages()
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithLessCornerDelay() async throws {
    
        sentMessages()
        
        try await Task.sleep(seconds: 4)
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithDelay() async throws {
    
        sentMessages()
        
        try await Task.sleep(seconds: 5)
        
        #expect(limits.canSendMessage() == true)
    }
    
    @Test func checkLimitWithTwoTimes() async throws {
    
        sentMessages()
        try await Task.sleep(seconds: 5)
        
        limits.markSentMessage()
        
        #expect(limits.canSendMessage() == true)
        
        sentMessages()
        
        #expect(limits.canSendMessage() == false)
    }

    private func sentMessages() {
        for _ in 0..<5 {
            limits.markSentMessage()
        }
    }
}
