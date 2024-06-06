import Foundation
import TipKit

@available(iOS 17.0, *)
struct GlobalSearchRelatedObjectsSwipeTip: Tip {
    
    var image: Image? {
        Image(asset: .handPointLeft)
    }
    
    var title: Text {
        Text(verbatim: Loc.GlobalSearch.Swipe.Tip.title)
    }
    
    var message: Text? {
        Text(verbatim: Loc.GlobalSearch.Swipe.Tip.subtitle)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(1)
        Tip.IgnoresDisplayFrequency(true)
    }
}

@available(iOS 17.0, *)
struct GlobalSearchRelatedObjectsSwipeTipView: View {
    let tip = GlobalSearchRelatedObjectsSwipeTip()
    
    var body: some View {
        TipView(tip)
            .tipBackground(Color.Shape.transperent)
            .tipCornerRadius(0)
    }
}

