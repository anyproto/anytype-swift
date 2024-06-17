import AnytypeCore
import Foundation

final class SpaceShareTipViewModel: ObservableObject {
    
    @Published var dismiss: Bool = false
    
    init() {}
    
    func onAppear() {
        AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .space)
    }
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .space, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        if #available(iOS 17.0, *) {
            SpaceShareTip().invalidate(reason: .tipClosed)
        }
    }
}
