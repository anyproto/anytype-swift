import Foundation
@testable import Anytype

final class ChatMessageLimitsDateProviderMock: ChatMessageLimitsDateProviderProtocol, @unchecked Sendable {
    
    var date: Date = Date()
    
    func currentDate() -> Date {
        return date
    }
}
