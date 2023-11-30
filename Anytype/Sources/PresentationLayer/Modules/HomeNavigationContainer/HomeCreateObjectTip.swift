import Foundation
import TipKit

@available(iOS 17.0, *)
struct HomeCreateObjectTip: Tip {
    
    @Parameter
    static var objectTpeChanged: Bool = false
    
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
            #Rule(Self.$objectTpeChanged) {
                $0 == true
            }
        ]
    }
}

@available(iOS 17.0, *)
fileprivate struct HomeCreateObjectTipModifier: ViewModifier {
    
    var tip = HomeCreateObjectTip()
    
    func body(content: Content) -> some View {
        content
            .popoverTip(tip, arrowEdge: .bottom)
    }
}

extension View {
    func popoverHomeCreateObjectTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(HomeCreateObjectTipModifier())
        } else {
            return self
        }
    }
}
