import AnytypeCore
import Foundation

final class SpaceHubTipViewModel: ObservableObject {
    
    @Published var dismiss: Bool = false
    
    init() {}
    
    func onAppear() {
        AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .vault, step: 1)
    }
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .vault, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        if #available(iOS 17.0, *) {
            SpaceHubTip().invalidate(reason: .tipClosed)
        }
    }
    
    func onStepChanged(step: Int) {
        AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .vault, step: step)
    }
}
