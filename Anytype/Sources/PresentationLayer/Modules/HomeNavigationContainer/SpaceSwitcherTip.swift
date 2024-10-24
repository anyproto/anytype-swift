import Foundation
import TipKit

@available(iOS 17.0, *)
struct SpaceSwitcherTip: Tip {
    
    @Parameter
    static var numberOfSpaceSwitches: Int = 0
    @Parameter
    static var openedSpaceSwitcher: Bool = false
    
    var title: Text {
        Text(Loc.SpaceSwitcher.Tip.title)
    }
    
    var message: Text? {
        Text(Loc.SpaceSwitcher.Tip.text)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$openedSpaceSwitcher) {
                $0 == false
            },
            #Rule(Self.$numberOfSpaceSwitches) {
                $0 >= 3
            }
        ]
    }
}

@available(iOS 17.0, *)
struct SpaceSwitcherTipView: View {
    
    @State private var size: CGSize = .zero
    var tip = SpaceSwitcherTip()
    
    var body: some View {
        GeometryReader { reader in
            TipView(tip, arrowEdge: .bottom)
                .readSize { newSize in
                    size = newSize
                }
                .position(x: reader.size.width * 0.5, y: -size.height*0.5)
                .onAppear {
                    AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .spaceSwitcher)
                }
        }
    }
}
