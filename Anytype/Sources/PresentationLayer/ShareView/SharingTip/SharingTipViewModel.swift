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
        onClose?(())
    }
    
    func tapShowShareMenu() {
        sharingTip.invalidate(reason: .tipClosed)
        
        guard let url = URL(string: "https://anytype.io") else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            onShareURL?(url)
        }
        
    }
}
