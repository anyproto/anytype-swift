import SwiftUI

struct SetFiltersSelectionView: View {
    @StateObject var viewModel: SetFiltersSelectionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .content:
                viewModel.contentView()
            case .empty:
                Spacer()
                button
            }
        }
    }
    
    private var button: some View {
        StandardButton(Loc.Set.Button.Title.apply, style: .primaryLarge) {
            viewModel.handleEmptyValue()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
