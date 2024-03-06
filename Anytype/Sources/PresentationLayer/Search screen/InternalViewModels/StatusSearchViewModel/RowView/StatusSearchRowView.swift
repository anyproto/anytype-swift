import SwiftUI

struct StatusSearchRowView: View {
    
    let viewModel: Model
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        content
            .divider()
            .padding(.horizontal, 20)
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            AnytypeText(viewModel.text, style: .relation1Regular, color: viewModel.color)
            Spacer(minLength: 12)
            selectionIndicatorViewModel.flatMap {
                SelectionIndicatorView(model: $0)
            }
        }
        .frame(height: 48)
    }
    
}

extension StatusSearchRowView {
    
    struct Model {
        
        let text: String
        let color: Color
        
    }

}
