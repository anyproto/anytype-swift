import AnytypeCore
import Foundation

@available(iOS 17.0, *)
final class SharingTipViewModel: ObservableObject {
    var onClose: RoutingAction<Void>?
    var onShareURL: RoutingAction<URL>?
    
    let sharingTip = SharingTip()
    
    init() {
        sharingTip.invalidate(reason: .tipClosed)
    }
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .sharingExtension, type: .close)
        onClose?(())
    }
    
    func tapShowShareMenu() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .sharingExtension, type: .showShareMenu)
        sharingTip.invalidate(reason: .tipClosed)
        
        guard let url = URL(string: "https://anytype.io") else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            onShareURL?(url)
        }
        
    }
}
