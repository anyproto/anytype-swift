import SwiftUI

struct TagSearchRowView: View {
    
    let viewModel: TagView.Model
    let relationStyle: RelationStyle
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(viewModel: viewModel, style: relationStyle)
            Spacer()
            selectionIndicatorViewModel.flatMap {
                SelectionIndicatorView(model: $0)
            }
        }
        .frame(height: 48)
        .divider()
        .padding(.horizontal, 20)
    }
    
}
