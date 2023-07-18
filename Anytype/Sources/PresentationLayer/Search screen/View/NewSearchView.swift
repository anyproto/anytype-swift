import SwiftUI

struct NewSearchView: View {
    
    @ObservedObject var viewModel: NewSearchViewModel

    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.style.needDragIndicator {
                DragIndicator()
            }
            TitleView(title: viewModel.title)
            SearchBar(text: $searchText, focused: true, placeholder: viewModel.searchPlaceholder)
            content
            
            viewModel.addButtonModel.flatMap {
                addButton(model: $0)
            }
        }
        .background(viewModel.style.backgroundColor)
        .onChange(of: searchText) { viewModel.didAskToSearch(text: $0) }
        .onAppear { viewModel.didAskToSearch(text: searchText) }
    }
    
    private var content: some View {
        Group {
            switch viewModel.state {
            case .resultsList(let model):
                searchResults(model: model)
            case .error(let error):
                NewSearchErrorView(error: error)
            }
        }
    }
    
    private func searchResults(model: ListModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !viewModel.createButtonModel.isDisabled {
                    ListCreateButton(text: viewModel.createButtonModel.title) {
                        viewModel.didTapCreateButton(title: searchText)
                    }
                }
                switch model {
                case .plain(let rows):
                    rowViews(rows: rows)
                case .sectioned(let sections):
                    ForEach(sections) { section in
                        Section(header: section.makeView()) {
                            rowViews(rows: section.rows)
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func rowViews(rows: [ListRowConfiguration]) -> some View {
        ForEach(rows) { row in
            Button {
                viewModel.didSelectRow(with: row.id)
            } label: {
                row.makeView()
            }
        }
    }
    
    private func addButton(model: AddButtonModel) -> some View {
        StandardButton(.text(viewModel.style.buttonTitle), info: model.counter > 0 ? "\(model.counter)" : nil, style: .primaryLarge) {
            viewModel.didTapAddButton()
        }
        .disabled(model.isDisabled)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
}

extension NewSearchView {
    enum Style {
        case `default`
        case embedded
        
        var needDragIndicator: Bool {
            switch self {
            case .default: return true
            case .embedded: return false
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .default: return Loc.add
            case .embedded: return Loc.Set.Button.Title.apply
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default: return .Background.secondary
            case .embedded: return .clear
            }
        }
        
        var isCreationModeAvailable: Bool {
            switch self {
            case .default: return true
            case .embedded: return false
            }
        }
    }
}
