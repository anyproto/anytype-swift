import SwiftUI

struct CountTagView: View {
    
    let count: Int
    let style: PropertyStyle
    
    var body: some View {
        TagView(
            config: TagView.Config(
                text: "+\(count)",
                textColor: .Text.secondary,
                backgroundColor: .Shape.transparentSecondary,
                textFont: style.font,
                guidlines: style.tagViewGuidlines
            )
        )
    }
}
