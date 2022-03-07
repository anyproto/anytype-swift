import SwiftUI

struct NewRelationOptionsSearchView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var presenter: NewRelationOptionsSearchPresenter
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: true)
            content
            addButton
        }
        .background(Color.backgroundSecondary)
        .onChange(of: searchText) { presenter.search(text: $0) }
        .onAppear { presenter.search(text: searchText) }
    }
    
    private var content: some View {
        Color.orange
//        Group {
//            if viewModel.searchResults.isEmpty {
//                emptyState
//            } else {
//                searchResults
//            }
//        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                "\("There is no object named".localized) \"\(searchText)\"",
                style: .uxBodyRegular,
                color: .textPrimary
            )
            .multilineTextAlignment(.center)
            AnytypeText(
                "Try to create a new one or search for something else".localized,
                style: .uxBodyRegular,
                color: .textSecondary
            )
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var searchResults: some View {
        Color.green
//        ScrollView {
//            LazyVStack(spacing: 0) {
//                ForEach(viewModel.searchResults) {
//                    RelationObjectsSearchRowView(data: $0, selectedIds: $viewModel.selectedOptionIds)
//                }
//            }
//            .padding(.bottom, 10)
//        }
        .divider()
    }
    
    private var addButton: some View {
        Color.red
//        StandardButton(disabled: viewModel.selectedOptionIds.isEmpty, text: "Add".localized, style: .primary) {
//            viewModel.didTapAddSelectedOptions()
//            presentationMode.wrappedValue.dismiss()
//        }
//        .if(viewModel.selectedOptionIds.isNotEmpty) {
//            $0.overlay(
//                HStack(spacing: 0) {
//                    Spacer()
//                    AnytypeText("\(viewModel.selectedOptionIds.count)", style: .relation1Regular, color: .textWhite)
//                        .frame(minWidth: 15, minHeight: 15)
//                        .padding(5)
//                        .background(Color.System.amber125)
//                        .clipShape(Circle())
//                    Spacer.fixedWidth(12)
//                }
//            )
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 20)
    }
}

//struct NewRelationOptionsSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewRelationOptionsSearchView()
//    }
//}
