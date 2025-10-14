import AnytypeCore
import Foundation

final class SharingTipViewModel: ObservableObject {
    
    let sharingTip = SharingTip()
    
    @Published var sharedUrl: URL?
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
        if sharedUrl.isNil {
            AnytypeAnalytics.instance().logClickOnboardingTooltip(tooltip: .sharingExtension, type: .showShareMenu)
        }
        sharedUrl = URL(string: "https://anytype.io")
    }
}
