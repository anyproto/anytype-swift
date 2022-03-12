import SwiftUI

struct StatusSearchRowView: View {
    
    let viewModel: Model
    
    var body: some View {
        label
            .divider()
            .padding(.horizontal, 20)
    }
    
    private var label: some View {
        HStack(spacing: 0) {
            AnytypeText(viewModel.text, style: .relation1Regular, color: viewModel.color.suColor)
            Spacer()
        }
        .frame(height: 48)
    }
    
}

extension StatusSearchRowView {
    
    struct Model {
        
        let text: String
        let color: UIColor
        
    }

}
