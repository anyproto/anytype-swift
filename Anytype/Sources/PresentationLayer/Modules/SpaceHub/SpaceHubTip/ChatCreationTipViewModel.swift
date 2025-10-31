import AnytypeCore
import Foundation

final class ChatCreationTipViewModel: ObservableObject {
    
    let chatCreationTip = ChatCreationTip()
    
    @Published var sharedUrl: URL?
    @Published var dismiss: Bool = false
    
    init() {}
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .chats, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        chatCreationTip.invalidate(reason: .tipClosed)
    }
}
