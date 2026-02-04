import AnytypeCore
import Foundation

@MainActor
@Observable
final class ChatCreationTipViewModel {

    let chatCreationTip = ChatCreationTip()

    var sharedUrl: URL?
    var dismiss: Bool = false
    
    init() {}
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .chats, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        chatCreationTip.invalidate(reason: .tipClosed)
    }
}
