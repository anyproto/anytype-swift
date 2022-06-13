import SwiftUI

struct SearchObjectRowView: View {
    
    let viewModel: Model
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        HStack(spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: viewModel.icon,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            content
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                text
                Spacer(minLength: 12)
                selectionIndicatorViewModel.flatMap {
                    SelectionIndicatorView(model: $0)
                }
            }
            Spacer()
            AnytypeDivider()
        }
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(
                viewModel.title,
                style: viewModel.subtitle != nil ? .previewTitle2Medium : .uxBodyRegular,
                color: .textPrimary
            ).lineLimit(1)
            if let subtitle = viewModel.subtitle {
                Spacer.fixedHeight(1)
                AnytypeText(subtitle, style: .relation2Regular, color: .textSecondary)
                    .lineLimit(1)
            }
        }
    }
    
}

extension SearchObjectRowView {
    
    struct Model {
        let icon: ObjectIconImage
        let title: String
        let subtitle: String?
    }
    
}
