import SwiftUI

struct TagSearchRowView: View {
    
    let config: TagView.Config
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(config: config)
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
