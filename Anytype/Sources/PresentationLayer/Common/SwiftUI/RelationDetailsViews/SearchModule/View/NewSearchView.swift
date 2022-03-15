import SwiftUI

struct NewSearchView: View {
    
    @ObservedObject var viewModel: NewSearchViewModel

    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: true)
            content
            addButton
        }
        .background(Color.backgroundSecondary)
        .onChange(of: searchText) { viewModel.didAskToSearch(text: $0) }
        .onAppear { viewModel.didAskToSearch(text: searchText) }
    }
    
    private var content: some View {
        Group {
            if viewModel.listModel.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
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
        ScrollView {
            LazyVStack(spacing: 0) {
                switch viewModel.listModel {
                case .plain(let rows):
                    rowViews(rows: rows)
                case .sectioned(let sections):
                    ForEach(sections) { section in
                        Section(
                            header: RelationOptionsSectionHeaderView(title: section.title)
                        ) {
                            rowViews(rows: section.rows)
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func rowViews(rows: [NewSearchRowConfiguration]) -> some View {
        ForEach(rows) { row in
            Button {
                viewModel.didSelectRow(with: row.id)
            } label: {
                row.rowBuilder()
            }
        }
    }
    
    private var addButton: some View {
        Color.yellow
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

//struct NewSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewSearchView()
//    }
//}
