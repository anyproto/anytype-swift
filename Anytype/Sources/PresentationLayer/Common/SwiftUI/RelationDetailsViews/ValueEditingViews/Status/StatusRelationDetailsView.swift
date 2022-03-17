import SwiftUI

struct StatusRelationDetailsView: View {
    
    @ObservedObject var viewModel: StatusRelationDetailsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(title: "Status")
            StatusSearchRowView(
                viewModel: StatusSearchRowView.Model(text: "sstst", color: .red)
            )
            Spacer.fixedHeight(20)
        }
    }
    
    
}
