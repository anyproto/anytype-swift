import Foundation
import TipKit

@available(iOS 17.0, *)
struct WidgetSwipeTip: Tip {
    
    var title: Text {
        Text(verbatim: Loc.Swipe.Tip.title)
    }
    
    var message: Text? {
        Text(verbatim: Loc.Swipe.Tip.subtitle)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
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
