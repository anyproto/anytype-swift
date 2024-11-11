import Foundation
import TipKit

@available(iOS 17.0, *)
struct ReturnToWidgetsTip: Tip {
    
    @Parameter
    static var numberOfBackTaps: Int = 0
    @Parameter
    static var usedLongpress: Bool = false
    
    var title: Text {
        Text(Loc.ReturnToWidgets.Tip.title)
    }
    
    var message: Text? {
        Text(Loc.ReturnToWidgets.Tip.text)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$usedLongpress) {
                $0 == false
            },
            #Rule(Self.$numberOfBackTaps) {
                $0 >= 8
            }
        ]
    }
}

@available(iOS 17.0, *)
struct ReturnToWidgetsTipView: View {
    
    @State private var size: CGSize = .zero
    var tip = ReturnToWidgetsTip()
    
    var body: some View {
        GeometryReader { reader in
            TipView(tip, arrowEdge: .bottom)
                .readSize { newSize in
                    size = newSize
                }
                .position(x: reader.size.width * 0.5, y: -size.height*0.5)
                .onAppear {
                    AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .returnToWidgets)
                }
        }
    }
}
