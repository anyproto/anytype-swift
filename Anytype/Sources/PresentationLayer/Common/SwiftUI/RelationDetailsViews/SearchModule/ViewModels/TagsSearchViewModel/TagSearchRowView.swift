import SwiftUI

struct TagSearchRowView: View {
    
    let viewModel: Model
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(tag: viewModel.tag, guidlines: viewModel.guidlines)
            Spacer()
        }
        .frame(height: 48)
        .divider()
        .padding(.horizontal, 20)
    }
    
}

extension TagSearchRowView {
    
    struct Model {
        let tag: Relation.Tag.Option
        let guidlines: TagView.Guidlines
    }
    
}
