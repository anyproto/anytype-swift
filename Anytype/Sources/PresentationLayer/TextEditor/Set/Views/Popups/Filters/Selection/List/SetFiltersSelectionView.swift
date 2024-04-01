import SwiftUI

struct SetFiltersSelectionView: View {
    @StateObject var viewModel: SetFiltersSelectionViewModel
    
    init(data: SetFiltersSelectionData, contentViewBuilder: SetFiltersContentViewBuilder, output: SetFiltersSelectionCoordinatorOutput?) {
        _viewModel = StateObject(wrappedValue: SetFiltersSelectionViewModel(data: data, contentViewBuilder: contentViewBuilder, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            viewModel.headerView()
            switch viewModel.state {
            case .content:
                viewModel.contentView()
            case .empty:
                Spacer.fixedHeight(8)
                button
            }
        }
        .if(viewModel.isCompactPresentationMode()) {
            $0.fitPresentationDetents()
        }
        .background(Color.Background.secondary)
    }
    
    private var button: some View {
        StandardButton(Loc.Set.Button.Title.apply, style: .primaryLarge) {
            viewModel.handleEmptyValue()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
