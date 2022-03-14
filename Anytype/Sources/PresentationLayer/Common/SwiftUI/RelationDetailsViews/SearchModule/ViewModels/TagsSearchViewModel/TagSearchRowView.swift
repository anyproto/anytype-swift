import SwiftUI

struct TagSearchRowView: View {
    
    let viewModel: TagView.Model
    let guidlines: TagView.Guidlines
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(viewModel: viewModel, guidlines: guidlines)
            Spacer()
        }
        .frame(height: 48)
        .divider()
        .padding(.horizontal, 20)
    }
    
}
