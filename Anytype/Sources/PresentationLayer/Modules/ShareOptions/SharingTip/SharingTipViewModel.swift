import AnytypeCore
import Foundation

@available(iOS 17.0, *)
final class SharingTipViewModel: ObservableObject {
    
    let sharingTip = SharingTip()
    
    let sharedUrl = URL(string: "https://anytype.io")
    @Published var showShare: Bool = false
    @Published var dismiss: Bool = false
    
    init() {}
    
    func tapClose() {
        AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .sharingExtension, type: .close)
        dismiss.toggle()
    }
    
    func onDisappear() {
        sharingTip.invalidate(reason: .tipClosed)
    }
    
    func tapShowShareMenu() {
        if !showShare {
            AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .sharingExtension, type: .showShareMenu)
        }
        showShare.toggle()
    }
}
