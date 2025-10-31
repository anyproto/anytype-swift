import Foundation
import TipKit

struct WidgetSwipeTip: Tip {

    @Parameter
    static var isFirstSession: Bool = false

    var title: Text {
        Text(verbatim: Loc.Swipe.Tip.title)
    }

    var message: Text? {
        Text(verbatim: Loc.Swipe.Tip.subtitle)
    }

    var options: [any TipOption] {
        Tip.MaxDisplayCount(3)
    }

    var rules: [Rule] {
        [
            #Rule(Self.$isFirstSession) { $0 == false }
        ]
    }
}

struct WidgetSwipeTipView: View {
    
    var tip = WidgetSwipeTip()
    
    var body: some View {
        TipView(tip)
            .tipBackground(Color.Background.primary)
            .onAppear {
                AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .swipeInWidgets)
            }
    }
}
