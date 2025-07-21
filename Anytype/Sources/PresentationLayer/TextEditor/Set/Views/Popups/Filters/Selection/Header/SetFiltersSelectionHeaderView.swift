import SwiftUI

struct SetFiltersSelectionHeaderView: View {
    @StateObject private var viewModel: SetFiltersSelectionHeaderViewModel
    
    init(data: SetFiltersSelectionHeaderData, output: (any SetFiltersSelectionCoordinatorOutput)?) {
        _viewModel = StateObject(wrappedValue: SetFiltersSelectionHeaderViewModel(data: data, output: output))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.Background.highlightedMedium)
                Image(asset: viewModel.headerConfiguration.iconAsset)
                    .foregroundColor(.Control.secondary)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(viewModel.headerConfiguration.title, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    viewModel.conditionTapped()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        AnytypeText(viewModel.headerConfiguration.condition, style: .relation1Regular)
                            .foregroundColor(.Text.secondary)
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
