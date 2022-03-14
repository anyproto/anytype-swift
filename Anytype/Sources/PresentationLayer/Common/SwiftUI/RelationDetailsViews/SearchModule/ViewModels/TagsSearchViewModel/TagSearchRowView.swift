import SwiftUI

struct TagSearchRowView: View {
    
    let viewModel: TagView.Model
    let guidlines: TagView.Guidlines
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(viewModel: viewModel, guidlines: guidlines)
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
