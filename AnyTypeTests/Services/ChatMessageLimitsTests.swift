import Testing
@testable import Anytype

struct ChatMessageLimitsTests {
    
    @Test func checkLimit() async throws {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithLessCornerDelay() async throws {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        try await Task.sleep(seconds: 4)
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithDelay() async throws {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        try await Task.sleep(seconds: 6)
        
        #expect(limits.canSendMessage() == true)
    }
    
    @Test func checkLimitWithTwoTimes() async throws {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        try await Task.sleep(seconds: 6)
        
        limits.markSentMessage()
        
        #expect(limits.canSendMessage() == true)
        
        sentMessages(limits)
        
        #expect(limits.canSendMessage() == false)
    }

    private func sentMessages(_ limits: ChatMessageLimits) {
        for _ in 0..<5 {
            limits.markSentMessage()
        }
    }
}
