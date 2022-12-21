import SwiftUI

struct CountTagView: View {
    
    let count: Int
    let style: RelationStyle
    
    var body: some View {
        TagView(
            viewModel: TagView.Model(
                text: "+\(count)",
                textColor: .Text.secondary,
                backgroundColor: .Stroke.transperent
            ),
            style: style
        )
    }
}
