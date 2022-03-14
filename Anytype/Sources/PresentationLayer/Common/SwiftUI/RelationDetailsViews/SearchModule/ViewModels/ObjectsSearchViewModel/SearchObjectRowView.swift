import SwiftUI

struct SearchObjectRowView: View {
    
    let viewModel: Model
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            Spacer.fixedWidth(12)
            content
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
    
    private var icon: some View {
        SwiftUIObjectIconImageView(iconImage: viewModel.icon, usecase: .dashboardSearch)
            .frame(width: 48, height: 48)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            AnytypeText(viewModel.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
                .frame(height: 20)
            
            Spacer.fixedHeight(1)
            AnytypeText(viewModel.title, style: .relation2Regular, color: .textSecondary)
                .lineLimit(1)
                .frame(height: 18)
            
            Spacer()
            AnytypeDivider()
        }
    }
}

extension SearchObjectRowView {
    
    struct Model {
        let icon: ObjectIconImage
        let title: String
        let subtitle: String
    }
    
}
