import Foundation
import TipKit

@available(iOS 17.0, *)
struct HomeCreateObjectTip: Tip {

    static let objectChangeType: Event = Event(id: "objectChangeType")
    
    var title: Text {
        Text(Loc.LongTapCreateTip.title)
    }
    
    var message: Text? {
        Text(Loc.LongTapCreateTip.message)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.objectChangeType) {
                $0.donations.count > 0
            }
        ]
    }
}

@available(iOS 17.0, *)
fileprivate struct HomeCreateObjectTipModifier: ViewModifier {
    
    private let tip = HomeCreateObjectTip()
    
    func body(content: Content) -> some View {
        content
            .popoverTip(tip, arrowEdge: .bottom)
    }
}

extension View {
    func popoverHomeCreateObjectTip() -> some View {
        if #available(iOS 17, *) {
            return self.modifier(HomeCreateObjectTipModifier())
        } else {
            return self
        }
    }
}
