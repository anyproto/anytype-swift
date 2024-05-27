import AnytypeCore
import Foundation

@available(iOS 17.0, *)
final class SpaceShareTipViewModel: ObservableObject {
    
    let tip = SpaceShareTip()
    
    @Published var dismiss: Bool = false
    
    init() {}
    
    func onAppear() {
        AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .spaceShare)
    }
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .spaceShare, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        tip.invalidate(reason: .tipClosed)
    }
}
