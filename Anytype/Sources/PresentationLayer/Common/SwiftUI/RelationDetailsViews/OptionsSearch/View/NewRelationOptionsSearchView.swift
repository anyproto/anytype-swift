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
        Group {
            if presenter.sections.isEmpty {
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
                ForEach(presenter.sections) { section in
                    sectionView(model: section)
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func sectionView(model: RelationOptionsSearchSectionModel) -> some View {
        Group {
            if let title = model.title, title.isNotEmpty {
                Section(
                    header: RelationOptionsSectionHeaderView(title: title)
                ) {
                    ForEach(model.rows) { row in
                        rowView(model: row)
                    }
                }
            } else {
                ForEach(model.rows) { row in
                    rowView(model: row)
                }
            }
        }
    }
    
    private func rowView(model: RelationOptionsSearchRowModel) -> some View {
        Group {
            switch model {
            case .object(let model):
                RelationOptionsSearchObjectRowView(model: model) {
                    presenter.didSelectOption(with: $0)
                }
            case .file(let model):
                RelationOptionsSearchObjectRowView(model: model) {
                    presenter.didSelectOption(with: $0)
                }
            case .tag(let model):
                RelationOptionsSearchTagRowView(model: model) {
                    presenter.didSelectOption(with: $0)
                }
            case .status(let model):
                RelationOptionsSearchStatusRowView(model: model) {
                    presenter.didSelectOption(with: $0)
                }
            }
        }
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
