import AnytypeCore
import Foundation

@available(iOS 17.0, *)
final class ChatCreationTipViewModel: ObservableObject {
    
    let chatCreationTip = ChatCreationTip()
    
    @Published var sharedUrl: URL?
    @Published var dismiss: Bool = false
    
    init() {}
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .chatCreation, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        chatCreationTip.invalidate(reason: .tipClosed)
    }
}
