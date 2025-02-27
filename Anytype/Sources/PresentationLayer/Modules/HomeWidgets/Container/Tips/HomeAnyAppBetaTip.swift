import Foundation
import TipKit

@available(iOS 17.0, *)
struct HomeAnyAppWidgetTip: Tip {
    
    var title: Text {
        Text(Loc.AnyApp.BetaAlert.title)
    }
    
    var message: Text? {
        Text(Loc.AnyApp.BetaAlert.description)
    }
    
    var options: [any TipOption] {
        Tip.IgnoresDisplayFrequency(true)
    }
    
    var rules: [Rule] {
        []
    }
}

@available(iOS 17.0, *)
struct HomeAnyAppWidgetTipView: View {
    
    var tip = HomeAnyAppWidgetTip()
    
    var body: some View {
        TipView(tip)
            .tipBackground(Color.Background.primary)
    }
}
