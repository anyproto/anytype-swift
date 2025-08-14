import Foundation

protocol ChatInviteStateServiceProtocol {
    func setShouldShowInvite(for spaceId: String)
    func shouldShowInvite(for spaceId: String) -> Bool
    func clearInviteState(for spaceId: String)
}

final class ChatInviteStateService: ChatInviteStateServiceProtocol {
    private var spacesWithInvite: Set<String> = []
    
    func setShouldShowInvite(for spaceId: String) {
        spacesWithInvite.insert(spaceId)
    }
    
    func shouldShowInvite(for spaceId: String) -> Bool {
        spacesWithInvite.contains(spaceId)
    }
    
    func clearInviteState(for spaceId: String) {
        spacesWithInvite.remove(spaceId)
    }
} 