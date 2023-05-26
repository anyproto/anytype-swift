import Foundation

struct HomeWidgetSubmoduleModel: Identifiable, Equatable {
    let blockId: String
    let provider: HomeSubmoduleProviderProtocol
    
    var id: String { blockId }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.blockId == rhs.blockId && lhs.provider === rhs.provider
    }
}
