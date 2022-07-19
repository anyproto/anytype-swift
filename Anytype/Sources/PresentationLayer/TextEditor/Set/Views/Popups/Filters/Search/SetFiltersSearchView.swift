import SwiftUI

struct SetFiltersSearchView<Content: View>: View {
    @EnvironmentObject var viewModel: SetFiltersSearchViewModel
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SetFiltersSearchHeaderView(viewModel: viewModel.headerViewModel)
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
        StandardButton(disabled: false, text: Loc.Set.Filters.Search.Button.title, style: .primary) {
            viewModel.handleEmptyValue()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
