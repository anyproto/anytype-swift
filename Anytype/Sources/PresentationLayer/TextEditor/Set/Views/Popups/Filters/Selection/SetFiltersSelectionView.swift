import SwiftUI

struct SetFiltersSelectionView<Content: View>: View {
    @EnvironmentObject var viewModel: SetFiltersSelectionViewModel
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SetFiltersSelectionHeaderView(viewModel: viewModel.headerViewModel)
            switch viewModel.state {
            case .content:
                content
            case .empty:
                Spacer()
                button
            }
        }
        Spacer()
    }
    
    private var button: some View {
        StandardButton(.text(Loc.Set.Button.Title.apply), style: .primaryLarge) {
            viewModel.handleEmptyValue()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
