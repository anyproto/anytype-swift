import Foundation
import TipKit

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

struct HomeAnyAppWidgetTipView: View {
    
    var tip = HomeAnyAppWidgetTip()
    
    var body: some View {
        TipView(tip)
    }
}
