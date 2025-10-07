import Testing
@testable import Anytype

@Suite(.serialized)
struct ChatMessageLimitsTests {
    
    private let dateProvider: ChatMessageLimitsDateProviderMock
    
    init() {
        let dateProvider = ChatMessageLimitsDateProviderMock()
        Container.shared.chatDateProvider.register { dateProvider }
        self.dateProvider = dateProvider
    }
    
    @Test func checkLimit() {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithLessCornerDelay() {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        dateProvider.date = dateProvider.date.addingTimeInterval(4.9)
        
        #expect(limits.canSendMessage() == false)
    }
    
    @Test func checkLimitWithDelay() {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        dateProvider.date = dateProvider.date.addingTimeInterval(5.1)
        
        #expect(limits.canSendMessage() == true)
    }
    
    @Test func checkLimitWithTwoTimes() {
        let limits = ChatMessageLimits()
        
        sentMessages(limits)
        
        dateProvider.date = dateProvider.date.addingTimeInterval(5.1)
        
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
