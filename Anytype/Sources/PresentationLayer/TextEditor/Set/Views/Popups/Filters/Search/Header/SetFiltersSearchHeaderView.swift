import SwiftUI

struct SetFiltersSearchHeaderView: View {
    @ObservedObject var viewModel: SetFiltersSearchHeaderViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.backgroundSelected)
                Image.createImage(viewModel.headerConfiguration.iconName)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(viewModel.headerConfiguration.title, style: .uxTitle2Medium, color: .textPrimary)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    viewModel.conditionTapped()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        AnytypeText(viewModel.headerConfiguration.condition, style: .relation1Regular, color: .textSecondary)
                        Image.arrowDown.foregroundColor(.textSecondary).padding(.top, 2)
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
}
