import SwiftUI

struct CountTagView: View {
    
    let count: Int
    let style: RelationStyle
    
    var body: some View {
        TagView(
            config: TagView.Config(
                text: "+\(count)",
                textColor: .Text.secondary,
                backgroundColor: .Shape.transperent,
                textFont: style.font,
                guidlines: style.tagViewGuidlines
            )
        )
    }
}
