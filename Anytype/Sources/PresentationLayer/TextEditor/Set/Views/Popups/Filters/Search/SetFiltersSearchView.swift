import SwiftUI

struct SetFiltersSearchView: View {
    @EnvironmentObject var viewModel: SetFiltersSearchViewModel
    
    var body: some View {
        DragIndicator()
        SetFiltersSearchHeaderView(viewModel: viewModel.headerViewModel)
        viewModel.makeSearchView()
        Spacer()
    }
}
