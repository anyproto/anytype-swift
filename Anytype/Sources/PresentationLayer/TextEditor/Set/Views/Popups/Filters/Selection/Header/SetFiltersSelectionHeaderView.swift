import SwiftUI

struct SetFiltersSelectionHeaderView: View {
    @ObservedObject var viewModel: SetFiltersSelectionHeaderViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.BackgroundNew.highlightedOfSelected)
                Image(asset: viewModel.headerConfiguration.iconAsset)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(viewModel.headerConfiguration.title, style: .uxTitle2Medium, color: .TextNew.primary)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    viewModel.conditionTapped()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        AnytypeText(viewModel.headerConfiguration.condition, style: .relation1Regular, color: .TextNew.secondary)
                        Image(asset: .arrowDown).foregroundColor(.TextNew.secondary).padding(.top, 2)
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 68)
        .padding(.horizontal, 20)
    }
}
