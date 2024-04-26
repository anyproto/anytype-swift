import SwiftUI

struct SetFiltersSelectionHeaderView: View {
    @StateObject var viewModel: SetFiltersSelectionHeaderViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.Background.highlightedOfSelected)
                Image(asset: viewModel.headerConfiguration.iconAsset)
                    .foregroundColor(.Button.active)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(viewModel.headerConfiguration.title, style: .uxTitle2Medium, color: .Text.primary)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    viewModel.conditionTapped()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        AnytypeText(viewModel.headerConfiguration.condition, style: .relation1Regular, color: .Text.secondary)
                        Image(asset: .arrowDown).foregroundColor(.Text.secondary).padding(.top, 2)
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
}
