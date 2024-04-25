import Foundation
import TipKit

@available(iOS 17.0, *)
struct HomeCreateObjectTip: Tip {
    
    @Parameter
    static var objectTypeChanged: Bool = false
    
    var title: Text {
        Text(verbatim: Loc.LongTapCreateTip.title)
    }
    
    var message: Text? {
        Text(verbatim: Loc.LongTapCreateTip.message)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$objectTypeChanged) {
                $0 == true
            }
        ]
    }
}

@available(iOS 17.0, *)
struct HomeTipView: View {
    
    @State private var size: CGSize = .zero
    var tip = HomeCreateObjectTip()
    
    var body: some View {
        GeometryReader { reader in
            TipView(tip, arrowEdge: .bottom)
                .readSize { newSize in
                    size = newSize
                }
                .position(x: reader.size.width * 0.5, y: -size.height*0.5)
                .onAppear {
                    AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .selectType)
                }
        }
    }
}
